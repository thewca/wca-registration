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
  before_action :validate_show_request, only: [:entry]
  before_action :ensure_lane_exists, only: [:create]
  before_action :validate_list_admin, only: [:list_admin]
  before_action :validate_update_request, only: [:update]
  before_action :validate_payment_ticket_request, only: [:payment_ticket]

  def create
    comment = params["competing"][:comment] || ""
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

    @competition = get_competition_info_or_render_error

    unless user_can_change_registration?
      raise RegistrationError.new(:unauthorized, ErrorCodes::USER_INSUFFICIENT_PERMISSIONS)
    end

    can_compete, reasons = UserApi.can_compete?(@user_id)
    unless can_compete
      raise RegistrationError.new(:unauthorized, reasons)
    end

    # Only admins can register when registration is closed
    if !CompetitionApi.competition_open?(@competition_id) && !(UserApi.can_administer?(@current_user, @competition_id) && @current_user == @user_id.to_s)
      raise RegistrationError.new(:forbidden, ErrorCodes::REGISTRATION_CLOSED)
    end

    validate_events_or_render_error
    validate_guests_or_render_error
  rescue RegistrationError => e
    render_error(e.http_status, e.error)
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

  def update
    guests = params[:guests]
    if params.key?(:competing)
      status = params["competing"][:status]
      comment = params["competing"][:comment]
      event_ids = params["competing"][:event_ids]
      admin_comment = params["competing"][:admin_comment]
    end

    begin
      registration = Registration.find("#{@competition_id}-#{@user_id}")
      updated_registration = registration.update_competing_lane!({ status: status, comment: comment, event_ids: event_ids, admin_comment: admin_comment, guests: guests })
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

  # You can either update your own registration or one for a competition you administer
  def validate_update_request
    @user_id, @competition_id = update_params

    @competition = get_competition_info_or_render_error
    @registration = Registration.find("#{@competition_id}-#{@user_id}")

    raise RegistrationError.new(:unauthorized, ErrorCodes::USER_INSUFFICIENT_PERMISSIONS) unless user_can_change_registration?
    raise RegistrationError.new(:unauthorized, ErrorCodes::USER_INSUFFICIENT_PERMISSIONS) if admin_fields_present? && !UserApi.can_administer?(@current_user, @competition_id)
    raise RegistrationError.new(:unprocessable_entity, ErrorCodes::GUEST_LIMIT_EXCEEDED) if params.key?(:guests) && !guests_valid?

    if params.key?(:competing)
      validate_status_or_render_error if params["competing"].key?(:status)
      validate_events_or_render_error if params["competing"].key?(:event_ids)
      raise RegistrationError.new(:unprocessable_entity, ErrorCodes::USER_COMMENT_TOO_LONG) if params["competing"].key?(:comment) && !comment_valid?
      raise RegistrationError.new(:unprocessable_entity, ErrorCodes::REQUIRED_COMMENT_MISSING) if
        !params["competing"].key?(:comment) && @competition[:competition_info]["force_comment_in_registration"]
    end
  rescue Dynamoid::Errors::RecordNotFound
    render_error(:not_found, ErrorCodes::REGISTRATION_NOT_FOUND)
  rescue RegistrationError => e
    render_error(e.http_status, e.error)
  end

  def show
    registration = get_single_registration(@user_id, @competition_id)
    render json: { registration: registration, status: 'ok' }
  rescue Dynamoid::Errors::RecordNotFound
    render json: { registration: {}, status: 'ok' }
  end

  # You can either view your own registration or one for a competition you administer
  def validate_show_registration
    @user_id, @competition_id = entry_params
    raise RegistrationError.new(:unauthorized, ErrorCodes::USER_INSUFFICIENT_PERMISSIONS) unless @current_user == @user_id || UserApi.can_administer?(@current_user, @competition_id)
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

  def validate_payment_ticket_request
    competition_id = params[:competition_id]
    unless CompetitionApi.uses_wca_payment?(competition_id)
      render_error(:forbidden, ErrorCodes::PAYMENT_NOT_ENABLED)
    end
    @registration = Registration.find("#{competition_id}-#{@current_user}")
    if @registration.competing_state.nil?
      render_error(:forbidden, ErrorCodes::PAYMENT_NOT_READY)
    end
  end

  def list
    competition_id = list_params
    registrations = get_registrations(competition_id, only_attending: true)
    render json: registrations
  rescue StandardError => e
    # Render an error response
    puts e
    Metrics.registration_dynamodb_errors_counter.increment
    render json: { error: "Error getting registrations #{e}" },
           status: :internal_server_error
  rescue RegistrationError => e
    render_error(e.http_status, e.error)
  end

  # To list Registrations in the admin view you need to be able to administer the competition
  def validate_list_admin
    @competition_id = list_params

    unless UserApi.can_administer?(@current_user, @competition_id)
      render_error(:unauthorized, ErrorCodes::USER_INSUFFICIENT_PERMISSIONS)
    end
  end

  def list_admin
    registrations = get_registrations(@competition_id)
    render json: registrations
  rescue StandardError => e
    puts e
    # Is there a reason we aren't using an error code here?
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

    def show_params
      params.require([:user_id, :competition_id, :competing])
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
      Registration.find("#{competition_id}-#{user_id}")
      true
    rescue Dynamoid::Errors::RecordNotFound
      false
    end

    def validate_guests_or_render_error
      raise RegistrationError.new(:unprocessable_entity, ErrorCodes::GUEST_LIMIT_EXCEEDED) if params.key?(:guests) && !guests_valid?
    end

    def guests_valid?
      @competition[:competition_info]["guest_entry_status"] != "restricted" || @competition[:competition_info]["guests_per_registration_limit"] >= params[:guests]
    end

    def comment_valid?
      params["competing"][:comment].length <= 240
    end

    def validate_events_or_render_error
      event_ids = params["competing"][:event_ids]

      if defined?(@registration)
        status = params["competing"].key?(:status) ? params["competing"][:status] : @registration.competing_status
      else
        status = "pending" # Assign it a placeholder status so that we don't throw errors when querying status
      end

      # Events list can only be empty if the status is cancelled - this allows for edge cases where an API user might send an empty event list,
      # or admin might want to remove events
      if event_ids == [] && status != "cancelled"
        raise RegistrationError.new(:unprocessable_entity, ErrorCodes::INVALID_EVENT_SELECTION)
      end

      # Event submitted must be held at the competition (unless the status is cancelled)
      # TODO: Do we have an edge case where someone can submit events not held at the competition if their status is cancelled? Shouldn't we say the events be a subset or empty?
      # like this: if !CompetitionApi.events_held?(event_ids, @competition_id) && event_ids != []
      if !CompetitionApi.events_held?(event_ids, @competition_id) && status != "cancelled"
        raise RegistrationError.new(:unprocessable_entity, ErrorCodes::INVALID_EVENT_SELECTION)
      end

      # Events can't be changed outside the edit_events deadline
      # TODO: Should an admin be able to override this?
      events_edit_deadline = Time.parse(@competition[:competition_info]["event_change_deadline_date"])
      raise RegistrationError.new(:forbidden, ErrorCodes::EVENT_EDIT_DEADLINE_PASSED) if events_edit_deadline < Time.now
    end

    def admin_fields_present?
      # There could be different admin fields in different lanes - define the admin fields per lane and check each
      competing_admin_fields = ["admin_comment"]

      if params.key?("competing") && params["competing"].keys.any? { |key| competing_admin_fields.include?(key) }
        true
      else
        false
      end
    end

    def user_can_change_registration?
      @current_user == @user_id.to_s || UserApi.can_administer?(@current_user, @competition_id)
    end

    def validate_status_or_render_error
      raise RegistrationError.new(:unprocessable_entity, ErrorCodes::INVALID_REQUEST_DATA) unless Registration::REGISTRATION_STATES.include?(params["competing"][:status])

      raise RegistrationError.new(:unauthorized, ErrorCodes::USER_INSUFFICIENT_PERMISSIONS) if
        Registration::ADMIN_ONLY_STATES.include?(params["competing"][:status]) && !UserApi.can_administer?(@current_user, @competition_id)

      competitor_limit = @competition[:competition_info]["competitor_limit"]
      raise RegistrationError.new(:forbidden, ErrorCodes::COMPETITOR_LIMIT_REACHED) if params["competing"][:status] == 'accepted' && Registration.count > competitor_limit
    end

    def get_competition_info_or_render_error
      if CompetitionApi.competition_exists?(@competition_id)
        CompetitionApi.get_competition_info(@competition_id)
      else
        raise RegistrationError.new(:not_found, ErrorCodes::COMPETITION_NOT_FOUND)
      end
    end
end
