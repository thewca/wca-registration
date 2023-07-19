# frozen_string_literal: true

require 'securerandom'
require 'jwt'
require_relative '../helpers/competition_api'
require_relative '../helpers/user_api'
require_relative '../helpers/error_codes'

class RegistrationController < ApplicationController
  skip_before_action :validate_token, only: [:list]
  # The order of the validations is important to not leak any non public info via the API
  # That's why we should always validate a request first, before taking any other before action
  # before_actions are triggered in the order they are defined
  before_action :validate_create_request, only: [:create]
  before_action :validate_entry_request, only: [:entry]
  before_action :ensure_lane_exists, only: [:create]
  before_action :validate_list_admin, only: [:list_admin]
  before_action :validate_update_request, only: [:update]

  # For a user to register they need to
  # 1) Need to actually be the user that they are trying to register
  # 2) Be Eligible to Compete (complete profile + not banned)
  # 3) Register for a competition that is open
  # 4) Register for events that are actually held at the competition
  # We need to do this in this order, so we don't leak user attributes

  def validate_create_request
    @user_id = registration_params[:user_id]
    @competition_id = registration_params[:competition_id]
    @event_ids = registration_params[:competing]["event_ids"]
    status = ""
    cannot_register_reason = ""

    unless @current_user == @user_id
      Metrics.registration_impersonation_attempt_counter.increment
      return render json: { error: ErrorCodes::USER_IMPERSONATION }, status: :forbidden
    end

    can_compete, reasons = UserApi.can_compete?(@user_id)
    unless can_compete
      status = :forbidden
      cannot_register_reason = reasons
    end

    # TODO: Create a proper competition_is_open? method (that would require changing test comps every once in a while)
    unless CompetitionApi.competition_exists?(@competition_id)
      status = :forbidden
      cannot_register_reasons = ErrorCodes::COMPETITION_CLOSED
    end

    if @event_ids.empty? || !CompetitionApi.events_held?(@event_ids, @competition_id)
      status = :bad_request
      cannot_register_reasons = ErrorCodes::COMPETITION_INVALID_EVENTS
    end

    unless cannot_register_reason.empty?
      Metrics.registration_validation_errors_counter.increment
      render json: { error: cannot_register_reasons }, status: status
    end
  end

  # We don't know which lane the user is going to complete first, this ensures that an entry in the DB exists
  # regardless of which lane the uses chooses to start with
  def ensure_lane_exists
    @queue_url = ENV["QUEUE_URL"] || $sqs.get_queue_url(queue_name: 'registrations.fifo').queue_url
    # TODO: Cache this call? We could keep a list of already created keys
    lane_created = begin
      Registration.find("#{@competition_id}-#{@user_id}")
      true
    rescue Dynamoid::Errors::RecordNotFound
      false
    end
    unless lane_created
      step_data = {
        user_id: @user_id,
        competition_id: @competition_id,
        step: 'Lane Init',
      }
      id = SecureRandom.uuid
      $sqs.send_message({
                          queue_url: @queue_url,
                          message_body: step_data.to_json,
                          message_group_id: id,
                          message_deduplication_id: id,
                        })
    end
  end

  def create
    comment = params[:comment] || ""
    guests = params[:guests] || 0

    id = SecureRandom.uuid

    step_data = {
      attendee_id: "#{@competition_id}-#{@user_id}",
      user_id: @user_id,
      competition_id: @competition_id,
      lane_name: 'competing',
      step: 'Event Registration',
      step_details: {
        registration_status: 'waiting',
        event_ids: @event_ids,
        comment: comment,
        guests: guests,
      },
    }

    $sqs.send_message({
                        queue_url: @queue_url,
                        message_body: step_data.to_json,
                        message_group_id: id,
                        message_deduplication_id: id,
                      })

    render json: { status: 'accepted', message: 'Started Registration Process' }, status: :accepted
  end

  # You can either update your own registration or one for a competition you administer
  def validate_update_request
    @user_id, @competition_id = update_params

    unless @current_user == @user_id || UserApi.can_administer?(@current_user, @competition_id)
      Metrics.registration_validation_errors_counter.increment
      render json: { error: ErrorCodes::USER_INSUFFICIENT_PERMISSIONS }, status: :forbidden
    end
  end

  def update
    status = params[:status]
    comment = params[:comment]
    admin_comment = params[:admin_comment]
    guests = params[:guests]
    event_ids = params[:event_ids]

    begin
      registration = Registration.find("#{@competition_id}-#{@user_id}")
      updated_registration = registration.update_competing_lane!({ status: status, comment: comment, event_ids: event_ids, admin_comment: admin_comment, guests: guests })
      render json: { status: 'ok', registration: {
        user_id: updated_registration["user_id"],
        event_ids: updated_registration.event_ids,
        registration_status: updated_registration.competing_status,
        registered_on: updated_registration["created_at"],
        comment: updated_registration.competing_comment,
        admin_comment: updated_registration.admin_comment,
        guests: updated_registration.guests,
      } }
    rescue StandardError => e
      puts e
      Metrics.registration_dynamodb_errors_counter.increment
      render json: { error: "Error Updating Registration: #{e.message}" },
             status: :internal_server_error
    end
  end

  # You can either view your own registration or one for a competition you administer
  def validate_entry_request
    @user_id, @competition_id = entry_params

    unless @current_user == @user_id || UserApi.can_administer?(@current_user, @competition_id)
      Metrics.registration_validation_errors_counter.increment
      render json: { error: ErrorCodes::USER_INSUFFICIENT_PERMISSIONS }, status: :forbidden
    end
  end

  def entry
    registration = get_single_registration(@user_id, @competition_id)
    render json: { registration: registration, status: 'ok' }
  rescue Dynamoid::Errors::RecordNotFound
    render json: { registration: {}, status: 'ok' }
  end

  def list
    competition_id = list_params
    competition_exists = CompetitionApi.competition_exists?(competition_id)
    registrations = get_registrations(competition_id, only_attending: true)
    registrations.each do |reg|
    end
    if competition_exists[:error]
      # Even if the competition service is down, we still return the registrations if they exists
      if registrations.count != 0 && competition_exists[:error] == ErrorCodes::COMPETITION_API_5XX
        return render json: registrations
      end
      return render json: { error: competition_exists[:error] }, status: competition_exists[:status]
    end
    # Render a success response
    render json: registrations
  rescue StandardError => e
    # Render an error response
    puts e
    Metrics.registration_dynamodb_errors_counter.increment
    render json: { error: "Error getting registrations #{e}" },
           status: :internal_server_error
  end

  # To list Registrations in the admin view you need to be able to administer the competition
  def validate_list_admin
    @competition_id = list_params

    unless UserApi.can_administer?(@current_user, @competition_id)
      Metrics.registration_validation_errors_counter.increment
      render json: { error: ErrorCodes::USER_INSUFFICIENT_PERMISSIONS }, status: 403
    end
  end

  def list_admin
    registrations = get_registrations(@competition_id)

    # Render a success response
    render json: registrations
  rescue StandardError => e
    # Render an error response
    puts e
    Metrics.registration_dynamodb_errors_counter.increment
    render json: { error: "Error getting registrations #{e}" },
           status: :internal_server_error
  end

  private

    REGISTRATION_STATUS = %w[waiting accepted deleted].freeze

    def registration_params
      params.require([:user_id, :competition_id])
      params.require(:competing).require(:event_ids)
      params
    end

    def entry_params
      params.require([:user_id, :competition_id])
    end

    def update_params
      params.require([:user_id, :competition_id])
    end

    def list_params
      params.require(:competition_id)
    end

    def get_registrations(competition_id, only_attending: false)
      if only_attending
        Registration.where(competition_id: competition_id, is_attending: true).all.map do |x|
          { user_id: x["user_id"],
            event_ids: x.event_ids }
        end
      else
        Registration.where(competition_id: competition_id).all.map do |x|
          { user_id: x["user_id"],
            event_ids: x.event_ids,
            registration_status: x.competing_status,
            registered_on: x["created_at"],
            comment: x.competing_comment,
            guests: x.guests,
            admin_comment: x.admin_comment }
        end
      end
    end

    def get_single_registration(user_id, competition_id)
      registration = Registration.find("#{competition_id}-#{user_id}")
      {
        user_id: registration["user_id"],
        event_ids: registration.event_ids,
        registration_status: registration.competing_status,
        registered_on: registration["created_at"],
        comment: registration.competing_comment,
        admin_comment: registration.admin_comment,
        guests: registration.guests,
      }
    end
end
