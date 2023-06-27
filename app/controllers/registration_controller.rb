# frozen_string_literal: true

require 'securerandom'
require 'jwt'
require_relative '../helpers/competition_api'
require_relative '../helpers/user_api'
require_relative '../helpers/error_codes'

class RegistrationController < ApplicationController
  skip_before_action :validate_token, only: [:list]
  before_action :validate_create_request, only: [:create]
  before_action :ensure_lane_exists, only: [:create]

  # For a user to register they need to
  # 1) Need to actually be the user that they are trying to register
  # 2) Be Eligible to Compete (complete profile + not banned)
  # 3) Register for a competition that is open
  # 4) Register for events that are actually held at the competition
  # We need to do this in this order, so we don't leak user attributes

  def validate_create_request
    @user_id, @competition_id, @event_ids = registration_params
    status = ""
    cannot_register_reasons = ""

    unless @decoded_token["data"]["user_id"] == @user_id
      Metrics.registration_impersonation_attempt_counter.increment
      return render json: { error: USER_IMPERSONATION }, status: :forbidden
    end

    can_compete, reasons = UserApi::can_compete?(@user_id)
    unless can_compete
      status = :forbidden
      cannot_register_reasons = reasons
    end
    # TODO: Create a proper competition_is_open? method (that would require changing test comps every once in a while)
    unless CompetitionApi::competition_exists?(@competition_id)
      status = :forbidden
      cannot_register_reasons = COMPETITION_CLOSED
    end

    if @event_ids.empty? || !CompetitionApi::events_held?(@event_ids, @competition_id)
      status = :bad_request
      cannot_register_reasons = COMPETITION_INVALID_EVENTS
    end

    unless cannot_register_reasons.empty?
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

    id = SecureRandom.uuid

    step_data = {
      user_id: @user_id,
      competition_id: @competition_id,
      lane_name: 'competing',
      step: 'Event Registration',
      step_details: {
        registration_status: 'waiting',
        event_ids: @event_ids,
        comment: comment,
      },
    }

    $sqs.send_message({
                        queue_url: @queue_url,
                        message_body: step_data.to_json,
                        message_group_id: id,
                        message_deduplication_id: id,
                      })

    render json: { status: 'ok', message: 'Started Registration Process' }
  end

  def update
    user_id = params[:user_id]
    competition_id = params[:competition_id]
    status = params[:status]
    comment = params[:comment]
    event_ids = params[:event_ids]

    begin
      registration = Registration.find("#{competition_id}-#{user_id}")
      updated_registration = registration.update_competing_lane!({ status: status, comment: comment, event_ids: event_ids })
      render json: { status: 'ok', registration: {
        user_id: updated_registration["user_id"],
        event_ids: updated_registration.event_ids,
        registration_status: updated_registration.competing_status,
        registered_on: updated_registration["created_at"],
        comment: updated_registration.competing_comment,
      } }
    rescue StandardError => e
      puts e
      Metrics.registration_dynamodb_errors_counter.increment
      render json: { status: "Error Updating Registration: #{e.message}" },
             status: :internal_server_error
    end
  end

  def entry
    user_id = params[:user_id]
    competition_id = params[:competition_id]
    begin
      registration = get_single_registration(user_id, competition_id)
      render json: { registration: registration, status: 'ok' }
    rescue Dynamoid::Errors::RecordNotFound
      render json: { registration: {}, status: 'ok' }
    end
  end

  def list
    competition_id = params[:competition_id]
    competition_exists = CompetitionApi.competition_exists?(competition_id)
    registrations = get_registrations(competition_id, only_attending: true)
    if competition_exists[:error]
      # Even if the competition service is down, we still return the registrations if they exists
      if registrations.count != 0 && competition_exists[:error] == COMPETITION_API_5XX
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
    render json: { status: "Error getting registrations #{e}" },
           status: :internal_server_error
  end

  def list_admin
    competition_id = params[:competition_id]
    registrations = get_registrations(competition_id)

    # Render a success response
    render json: registrations
  rescue StandardError => e
    # Render an error response
    puts e
    Metrics.registration_dynamodb_errors_counter.increment
    render json: { status: "Error getting registrations #{e}" },
           status: :internal_server_error
  end

  private

    REGISTRATION_STATUS = %w[waiting accepted deleted].freeze

    def registration_params
      params.require([:user_id, :competition_id, :event_ids])
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
            comment: x.competing_comment }
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
      }
    end
end
