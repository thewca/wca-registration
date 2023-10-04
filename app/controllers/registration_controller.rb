# frozen_string_literal: true

require 'securerandom'
require 'jwt'
require 'time'
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
  before_action :validate_payment_ticket_request, only: [:payment_ticket]

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

    # This could be split out into a "validate competition exists" method
    # Validations could also be restructured to be a bunch of private methods that validators call
    @competition = CompetitionApi.get_competition_info(@competition_id)

    unless CompetitionApi.competition_exists?(@competition_id) == true
      return render_error(:not_found, ErrorCodes::COMPETITION_NOT_FOUND)
    end

    unless @current_user == @user_id.to_s || UserApi.can_administer?(@current_user, @competition_id)
      Metrics.registration_impersonation_attempt_counter.increment
      return render json: { error: ErrorCodes::USER_IMPERSONATION }, status: :unauthorized
    end

    can_compete, reasons = UserApi.can_compete?(@user_id)
    unless can_compete
      if reasons == ErrorCodes::USER_IS_BANNED
        return render_error(:forbidden, ErrorCodes::USER_IS_BANNED)
      else
        return render_error(:unauthorized, ErrorCodes::USER_PROFILE_INCOMPLETE)
      end
      # status = :forbidden
      # cannot_register_reason = reasons
    end

    unless CompetitionApi.competition_open?(@competition_id)
      unless UserApi.can_administer?(@current_user, @competition_id) && @current_user == @user_id.to_s
        # Admin can only pre-regiser for themselves, not for other users
        return render_error(:forbidden, ErrorCodes::COMPETITION_CLOSED)
      end
    end

    if @event_ids.empty? || !CompetitionApi.events_held?(@event_ids, @competition_id)
      return render_error(:unprocessable_entity, ErrorCodes::COMPETITION_INVALID_EVENTS)
    end

    if params.key?(:guests) && !guests_valid?
      render_error(:unprocessable_entity, ErrorCodes::GUEST_LIMIT_EXCEEDED)
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
    @admin_comment = params[:admin_comment]

    # Check if competition exists
    if CompetitionApi.competition_exists?(@competition_id) == true
      @competition = CompetitionApi.get_competition_info(@competition_id)
    else
      return render_error(:not_found, ErrorCodes::COMPETITION_NOT_FOUND)
    end

    # Check if competition exists
    unless registration_exists?(@user_id, @competition_id)
      return render_error(:not_found, ErrorCodes::REGISTRATION_NOT_FOUND)
    end

    @registration = Registration.find("#{@competition_id}-#{@user_id}")

    # Only the user or an admin can update a user's registration
    unless @current_user == @user_id || UserApi.can_administer?(@current_user, @competition_id)
      return render_error(:unauthorized, ErrorCodes::USER_IMPERSONATION)
    end

    # User must be an admin if they're changing admin properties
    admin_fields = [@admin_comment]
    if (admin_fields.any? { |field| !(field.nil?) }) && !(UserApi.can_administer?(@current_user, @competition_id))
      return render_error(:unauthorized, ErrorCodes::USER_INSUFFICIENT_PERMISSIONS)
    end

    if params.key?(:status)
      validate_status_or_render_error
    end

    if params.key?(:event_ids)
      validate_events_or_render_error
    end

    params.key?(:guests)
    if params.key?(:guests) && !guests_valid?
      return render_error(:unprocessable_entity, ErrorCodes::GUEST_LIMIT_EXCEEDED)
    end

    if params.key?(:comment) && !comment_valid?
      return render_error(:unprocessable_entity, ErrorCodes::USER_COMMENT_TOO_LONG)
    end

    if !params.key?(:comment) && @competition[:competition_info]["force_comment_in_registration"]
      render_error(:unprocessable_entity, ErrorCodes::REQUIRED_COMMENT_MISSING)
    end
  end

  def update
    status = params[:status]
    comment = params[:comment]
    guests = params[:guests]
    event_ids = params[:event_ids]

    begin
      registration = Registration.find("#{@competition_id}-#{@user_id}")
      updated_registration = registration.update_competing_lane!({ status: status, comment: comment, event_ids: event_ids, admin_comment: @admin_comment, guests: guests })
      render json: { status: 'ok', registration: {
        user_id: updated_registration["user_id"],
        registered_event_ids: updated_registration.registered_event_ids,
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
      return render_error(:unauthorized, ErrorCodes::USER_IMPERSONATION)
    end
  end

  def entry
    registration = get_single_registration(@user_id, @competition_id)
    render json: { registration: registration, status: 'ok' }
  rescue Dynamoid::Errors::RecordNotFound
    render json: { registration: {}, status: 'ok' }
  end

  def validate_payment_ticket_request
    competition_id = params[:competition_id]
    unless CompetitionApi.uses_wca_payment?(competition_id)
      Metrics.registration_validation_errors_counter.increment
      render json: { error: ErrorCodes::PAYMENT_NOT_ENABLED }, status: :forbidden
    end
    @registration = Registration.find("#{competition_id}-#{@current_user}")
    if @registration.competing_state.nil?
      Metrics.registration_validation_errors_counter.increment
      render json: { error: ErrorCodes::PAYMENT_NOT_READY }, status: :forbidden
    end
  end

  def payment_ticket
    refresh = params[:refresh]
    if refresh || @registration.payment_ticket.nil?
      amount, currency_code = CompetitionApi.payment_info(@registration[:competition_id])
      ticket, account_id = PaymentApi.get_ticket(@registration[:attendee_id], amount, currency_code)
      @registration.init_payment_lane(amount, currency_code, ticket)
    else
      ticket = @registration.payment_ticket
    end
    render json: { client_secret_id: ticket, connected_account_id: account_id }
  end

  def list
    competition_id = list_params
    competition_info = CompetitionApi.get_competition_info(competition_id)
    puts "comp info in controller: #{competition_info}"

    if competition_info[:competition_exists?] == false
      return render json: { error: competition_info[:error] }, status: competition_info[:status]
    end

    registrations = get_registrations(competition_id, only_attending: true)

    if registrations.count == 0 && competition_info[:error] == ErrorCodes::COMPETITION_API_5XX
      return render json: { error: competition_info[:error] }, status: competition_info[:status]
    end
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
      render json: { error: ErrorCodes::USER_INSUFFICIENT_PERMISSIONS }, status: 401
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

    def registration_exists?(user_id, competition_id)
      begin
        Registration.find("#{competition_id}-#{user_id}")
        true
      rescue Dynamoid::Errors::RecordNotFound
        false
      end
    end

    def guests_valid?
      @competition[:competition_info]["guest_entry_status"] != "restricted" || @competition[:competition_info]["guests_per_registration_limit"] >= params[:guests]
    end

    def comment_valid?
      params[:comment].length <= 240
    end

    def validate_events_or_render_error
      event_ids = params[:event_ids]
      status = params.key?(:status) ? params[:status] : @registration.competing_status

      # Events list can only be empty if the status is deleted
      if event_ids == [] && status != "deleted"
        return render_error(:unprocessable_entity, ErrorCodes::INVALID_EVENT_SELECTION)
      end

      if !CompetitionApi.events_held?(event_ids, @competition_id) && status != "deleted"
        return render_error(:unprocessable_entity, ErrorCodes::INVALID_EVENT_SELECTION)
      end

      events_edit_deadline = Time.parse(@competition[:competition_info]["event_change_deadline_date"])
      return render_error(:forbidden, ErrorCodes::EVENT_EDIT_DEADLINE_PASSED) if events_edit_deadline < Time.now
    end

    def validate_status_or_render_error
      unless Registration::REGISTRATION_STATES.include?(params[:status])
        return render_error(:unprocessable_entity, ErrorCodes::INVALID_REQUEST_DATA)
      end

      if Registration::ADMIN_ONLY_STATES.include?(params[:status]) && !UserApi.can_administer?(@current_user, @competition_id)
        return render_error(:unauthorized, ErrorCodes::USER_INSUFFICIENT_PERMISSIONS)
      end

      competitor_limit = @competition[:competition_info]["competitor_limit"]
      if params[:status] == 'accepted' && Registration.count > competitor_limit
        render_error(:forbidden, ErrorCodes::COMPETITOR_LIMIT_REACHED)
      end
    end
end
