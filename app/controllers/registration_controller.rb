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
  before_action :validate_show_registration, only: [:show]
  before_action :ensure_lane_exists, only: [:create]
  before_action :validate_list_admin, only: [:list_admin]
  before_action :validate_update_request, only: [:update]
  before_action :validate_payment_ticket_request, only: [:payment_ticket]

  def create
    comment = params['competing'][:comment] || ''
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
    @event_ids = registration_params[:competing]['event_ids']

    # TODO: Rename @comeptition to competition_info - make it clear that it's a DataClass, not a model object
    @competition = CompetitionApi.find!(@competition_id)

    puts "current user: #{@current_user}"
    RegistrationChecker.create_registration_allowed!(registration_params, CompetitionApi.find!(@competition_id), @current_user)

    # user_can_create_registration!

    # can_compete, reasons = UserApi.can_compete?(@user_id)
    # raise RegistrationError.new(:unauthorized, reasons) unless can_compete

    # validate_events!
    # raise RegistrationError.new(:unprocessable_entity, ErrorCodes::GUEST_LIMIT_EXCEEDED) if params.key?(:guests) && @competition.guest_limit_exceeded?(params[:guests])
  rescue RegistrationError => e
    render_error(e.http_status, e.error)
  end

  # We don't know which lane the user is going to complete first, this ensures that an entry in the DB exists
  # regardless of which lane the uses chooses to start with
  def ensure_lane_exists
    @queue_url = ENV['QUEUE_URL'] || $sqs.get_queue_url(queue_name: 'registrations.fifo').queue_url
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
    status = params.dig('competing', 'status')
    comment = params.dig('competing', 'comment')
    event_ids = params.dig('competing', 'event_ids')
    admin_comment = params.dig('competing', 'admin_comment')

    begin
      registration = Registration.find("#{@competition_id}-#{@user_id}")
      updated_registration = registration.update_competing_lane!({ status: status, comment: comment, event_ids: event_ids, admin_comment: admin_comment, guests: guests })
      render json: { status: 'ok', registration: {
        user_id: updated_registration['user_id'],
        guests: updated_registration.guests,
        competing: {
          event_ids: updated_registration.registered_event_ids,
          registration_status: updated_registration.competing_status,
          registered_on: updated_registration['created_at'],
          comment: updated_registration.competing_comment,
          admin_comment: updated_registration.admin_comment,
        },
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
    puts "update params: #{params}"
    @user_id = params[:user_id]
    @competition_id = params[:competition_id]

    # @registration = Registration.find("#{@competition_id}-#{@user_id}")

    RegistrationChecker.update_registration_allowed!(params, CompetitionApi.find!(@competition_id), @current_user)
    # raise RegistrationError.new(:unauthorized, ErrorCodes::USER_INSUFFICIENT_PERMISSIONS) unless is_admin_or_current_user?
    # raise RegistrationError.new(:unauthorized, ErrorCodes::USER_INSUFFICIENT_PERMISSIONS) if admin_fields_present? && !UserApi.can_administer?(@current_user, @competition_id)
    # raise RegistrationError.new(:unprocessable_entity, ErrorCodes::GUEST_LIMIT_EXCEEDED) if params.key?(:guests) && @competition.guest_limit_exceeded?(params[:guests])

    # if params.key?(:competing)
    #   validate_status! if params['competing'].key?(:status)
    #   validate_events! if params['competing'].key?(:event_ids)
    #   raise RegistrationError.new(:unprocessable_entity, ErrorCodes::USER_COMMENT_TOO_LONG) if params['competing'].key?(:comment) && !comment_valid?
    #   raise RegistrationError.new(:unprocessable_entity, ErrorCodes::REQUIRED_COMMENT_MISSING) if !params['competing'].key?(:comment) && @competition.force_comment?
    # end
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
    @user_id, @competition_id = show_params
    raise RegistrationError.new(:unauthorized, ErrorCodes::USER_INSUFFICIENT_PERMISSIONS) unless
      @current_user == @user_id || UserApi.can_administer?(@current_user, @competition_id)
  end

  def payment_ticket
    refresh = params[:refresh]
    if refresh || @registration.payment_ticket.nil?
      amount, currency_code = @competition.payment_info
      ticket = PaymentApi.get_ticket(@registration[:attendee_id], amount, currency_code)
      @registration.init_payment_lane(amount, currency_code, ticket)
    else
      ticket = @registration.payment_ticket
    end
    render json: { id: ticket, status: @registration.payment_status }
  end

  def validate_payment_ticket_request
    competition_id = params[:competition_id]
    @competition = CompetitionApi.find!(competition_id)
    render_error(:forbidden, ErrorCodes::PAYMENT_NOT_ENABLED) unless @competition.using_wca_payment?

    @registration = Registration.find("#{competition_id}-#{@current_user}")
    render_error(:forbidden, ErrorCodes::PAYMENT_NOT_READY) if @registration.nil? || @registration.competing_status.nil?
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
      params.require([:user_id, :competition_id])
    end

    def update_params
      params.require([:user_id, :competition_id])
      params.permit(:guests, competing: [:status, :comment, { event_ids: [] }, :admin_comment])
    end

    def list_params
      params.require(:competition_id)
    end

    def get_registrations(competition_id, only_attending: false)
      if only_attending
        Registration.where(competition_id: competition_id, is_attending: true).all.map do |x|
          { user_id: x['user_id'],
            competing: {
              event_ids: x.event_ids,
            } }
        end
      else
        Registration.where(competition_id: competition_id).all.map do |x|
          { user_id: x['user_id'],
            competing: {
              event_ids: x.event_ids,
              registration_status: x.competing_status,
              registered_on: x['created_at'],
              comment: x.competing_comment,
              admin_comment: x.admin_comment,
            },
            payment: {
              payment_status: x.payment_status,
              updated_at: x.payment_date,
            },
            guests: x.guests }
        end
      end
    end

    def get_single_registration(user_id, competition_id)
      registration = Registration.find("#{competition_id}-#{user_id}")
      {
        user_id: registration['user_id'],
        guests: registration.guests,
        competing: {
          event_ids: registration.event_ids,
          registration_status: registration.competing_status,
          registered_on: registration['created_at'],
          comment: registration.competing_comment,
          admin_comment: registration.admin_comment,
        },
        payment: {
          payment_status: registration.payment_status,
          updated_at: registration.payment_date,
        },
      }
    end

    def registration_exists?(user_id, competition_id)
      Registration.find("#{competition_id}-#{user_id}")
      true
    rescue Dynamoid::Errors::RecordNotFound
      false
    end

    def comment_valid?
      params['competing'][:comment].length <= 240
    end

    def validate_events!
      event_ids = params['competing'][:event_ids]
      if defined?(@registration) && params['competing'].key?(:status) && params['competing'][:status] == 'cancelled'
        # If status is cancelled, events can only be empty or match the old events list
        # This allows for edge cases where an API user might send an empty event list/the old event list, or admin might want to remove events
        raise RegistrationError.new(:unprocessable_entity, ErrorCodes::INVALID_EVENT_SELECTION) unless event_ids == [] || event_ids == @registration.event_ids
      else
        # Event submitted must be held at the competition
        raise RegistrationError.new(:unprocessable_entity, ErrorCodes::INVALID_EVENT_SELECTION) unless @competition.events_held?(event_ids)
      end

      # Events can't be changed outside the edit_events deadline
      # TODO: Should an admin be able to override this?
      if @competition.event_change_deadline.present?
        events_edit_deadline = Time.parse(@competition.event_change_deadline)
        raise RegistrationError.new(:forbidden, ErrorCodes::EVENT_EDIT_DEADLINE_PASSED) if events_edit_deadline < Time.now
      end
    end

    def admin_fields_present?
      # There could be different admin fields in different lanes - define the admin fields per lane and check each
      competing_admin_fields = ['admin_comment']

      params.key?('competing') && params['competing'].keys.any? { |key| competing_admin_fields.include?(key) }
    end

    def user_can_create_registration!
      # Only an admin or the user themselves can create a registration for the user
      raise RegistrationError.new(:unauthorized, ErrorCodes::USER_INSUFFICIENT_PERMISSIONS) unless is_admin_or_current_user?

      # Only admins can register when registration is closed, and they can only register for themselves - not for other users
      raise RegistrationError.new(:forbidden, ErrorCodes::REGISTRATION_CLOSED) unless @competition.registration_open? || organizer_signing_up_themselves?
    end

    def organizer_signing_up_themselves?
      @competition.is_organizer_or_delegate?(@current_user) && (@current_user == @user_id.to_s)
    end

    def is_admin_or_current_user?
      # Only an admin or the user themselves can create a registration for the user
      # One case where admins need to create registrations for users is if a 3rd-party registration system is being used, and registration data is being
      # passed to the Registration Service from it
      (@current_user == @user_id.to_s) || UserApi.can_administer?(@current_user, @competition_id)
    end

    def validate_status!
      raise RegistrationError.new(:unprocessable_entity, ErrorCodes::INVALID_REQUEST_DATA) unless Registration::REGISTRATION_STATES.include?(params['competing'][:status])

      raise RegistrationError.new(:unauthorized, ErrorCodes::USER_INSUFFICIENT_PERMISSIONS) if
        Registration::ADMIN_ONLY_STATES.include?(params['competing'][:status]) && !UserApi.can_administer?(@current_user, @competition_id)

      raise RegistrationError.new(:forbidden, ErrorCodes::COMPETITOR_LIMIT_REACHED) if params['competing'][:status] == 'accepted' && Registration.count > @competition.competitor_limit
    end
end
