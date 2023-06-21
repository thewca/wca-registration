# frozen_string_literal: true

require 'securerandom'
require_relative '../helpers/competition_api'
require_relative '../helpers/user_api'

class RegistrationController < ApplicationController
  prepend_before_action :validate_create_request, only: [:create]
  prepend_before_action :validate_update_request, only: [:update]
  before_action :ensure_lane_exists, only: [:create]

  # For a user to register they need to
  # 1) Have a complete Profile
  # 2) Be not banned
  # 3) Register for a competition that is open
  # 4) Register for events that are actually held at the competition

  def validate_create_request
    required_params = registration_params
    @user_id = required_params[:user_id]
    @competition_id = required_params[:competition_id]
    @event_ids = required_params[:event_ids]
    status = ""
    cannot_register_reasons = ""

    unless UserApi::profile_complete?(@user_id)
      status = :forbidden
      cannot_register_reasons = 'User cannot register for competition: Your profile is not complete'
    end

    if UserApi::is_banned?(@user_id)
      status = :forbidden
      cannot_register_reasons = 'User cannot register for competition: You are banned from competing'
    end

    unless CompetitionApi::is_open?(@competition_id)
      status = :forbidden
      cannot_register_reasons = 'User cannot register for competition: The Competition is not open'
    end

    if @event_ids.empty? || !CompetitionApi::events_held?(@event_ids, @competition_id)
      status = :bad_request
      cannot_register_reasons = 'User cannot register for competition: Invalid events specified'
    end

    unless cannot_register_reasons.empty?
      Metrics.registration_validation_errors_counter.increment
      return render json: { status: cannot_register_reasons }, status: status
    end
  end

  # For a user to update they need to
  # 1) Be already Registered to the competition
  # 2) Registration is open(?)
  # 3) Register for events that are actually held at the competition

  def validate_update_request
    required_params = update_params
    @user_id = required_params[:user_id]
    @competition_id = required_params[:competition_id]
    @event_ids = params[:event_ids]
    status = ""
    cannot_update_reasons = ""

    begin
      @registration = Registrations.find("#{competition_id}-#{user_id}")
    rescue Dynamoid::Errors::RecordNotFound
      cannot_update_reasons = "User cannot update: Not registered"
    end

    unless CompetitionApi::is_open?(@competition_id)
      status = :forbidden
      cannot_update_reasons = 'User cannot update for competition: The Competition is not open'
    end

    if @event_ids.empty? || !CompetitionApi::events_held?(@event_ids, @competition_id)
      status = :bad_request
      cannot_update_reasons = 'User cannot register for competition: Invalid events specified'
    end

    unless cannot_update_reasons.empty?
      Metrics.registration_validation_errors_counter.increment
      return render json: { status: cannot_update_reasons }, status: status
    end
  end

  def ensure_lane_exists
    user_id = params[:competitor_id]
    competition_id = params[:competition_id]
    @queue_url = ENV["QUEUE_URL"] || $sqs.get_queue_url(queue_name: 'registrations.fifo').queue_url
    lane_created = begin
      Registrations.find("#{competition_id}-#{user_id}")
      true
    rescue Dynamoid::Errors::RecordNotFound
      false
    end
    unless lane_created
      step_data = {
        user_id: user_id,
        competition_id: competition_id,
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
    id = SecureRandom.uuid

    step_data = {
      user_id: @user_id,
      competition_id: @competition_id,
      lane_name: 'Competing',
      step: 'Event Registration',
      step_details: {
        registration_status: 'waiting',
        event_ids: @event_ids,
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
    status = params[:status]

    begin
      updated_lanes = @registration.lanes.map { |lane|
        if lane.name == "Competing"
          lane.lane_state = status
        end
        lane
      }
      registration.update_attributes(lanes: updated_lanes)
      # Render a success response
      render json: { status: 'ok' }
    rescue StandardError => e
      # Render an error response
      puts e
      Metrics.registration_dynamodb_errors_counter.increment
      render json: { status: "Error Updating Registration: #{e.message}" },
             status: :internal_server_error
    end
  end

  def list
    competition_id = params[:competition_id]
    registrations = get_registrations(competition_id)

    # Render a success response
    render json: registrations
  rescue StandardError => e
    # Render an error response
    puts e
    Metrics.registration_dynamodb_errors_counter.increment
    render json: { status: "Error getting registrations" },
           status: :internal_server_error
  end

  private

    REGISTRATION_STATUS = %w[waiting accepted].freeze

    def registration_params
      params.require([:user_id, :competition_id, :event_ids])
    end

    def update_params
      params.require([:user_id, :competition_id])
    end

    def get_registrations(competition_id)
      # Query DynamoDB for registrations with the given competition_id using the Global Secondary Index
      # TODO make this more beautiful and not break if there are more then one lane
      Registrations.where(competition_id: competition_id).all.map { |x| { competitor_id: x["user_id"], event_ids: x["lanes"][0].step_details["event_ids"], registration_status: x["lanes"][0].lane_state } }
    end
end
