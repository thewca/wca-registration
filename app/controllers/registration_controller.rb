# frozen_string_literal: true

require 'securerandom'
require_relative '../helpers/competition_api'
require_relative '../helpers/competitor_api'

class RegistrationController < ApplicationController
  before_action :ensure_lane_exists, only: [:create]

  def ensure_lane_exists
    user_id = params[:competitor_id]
    competition_id = params[:competition_id]
    @queue_url = ENV["QUEUE_URL"] || $sqs.get_queue_url(queue_name: 'registrations.fifo').queue_url
    # TODO: Cache this call?
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
    competitor_id = params[:competitor_id]
    competition_id = params[:competition_id]
    event_ids = params[:event_ids]
    comment = params[:comment] || ""

    unless validate_request(competitor_id, competition_id) && !event_ids.empty?
      Metrics.registration_validation_errors_counter.increment
      return render json: { status: 'User cannot register for competition' }, status: :forbidden
    end

    id = SecureRandom.uuid

    step_data = {
      user_id: competitor_id,
      competition_id: competition_id,
      lane_name: 'Competing',
      step: 'Event Registration',
      step_details: {
        registration_status: 'waiting',
        event_ids: event_ids,
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
    user_id = params[:competitor_id]
    competition_id = params[:competition_id]
    status = params[:status]
    comment = params[:comment]
    event_ids = params[:event_ids]

    unless validate_request(user_id, competition_id)
      Metrics.registration_validation_errors_counter.increment
      return render json: { status: 'User cannot register, wrong format' }, status: :forbidden
    end
    begin
      registration = Registrations.find("#{competition_id}-#{user_id}")
      updated_lanes = registration.lanes.map { |lane|
        if lane.name == "Competing"
          if status.present?
            lane.lane_state = status
          end
          if comment.present?
            lane.step_details["comment"] = comment
          end
          if event_ids.present?
            lane.step_details["event_ids"] = event_ids
          end
        end
        lane
      }
      if status == "accepted"
        registration.update_attributes(lanes: updated_lanes, is_attending: true)
      else
        registration.update_attributes(lanes: updated_lanes)
      end

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

  def entry
    user_id = params[:user_id]
    competition_id = params[:competition_id]
    unless validate_request(user_id, competition_id)
      Metrics.registration_validation_errors_counter.increment
      return render json: { status: "Can't get registration, wrong format" }, status: :forbidden
    end
    begin
      registration = Registrations.find("#{competition_id}-#{user_id}")
      render json: { registration: {
        user_id: registration["user_id"],
        event_ids: registration["lanes"][0].step_details["event_ids"],
        registration_status: registration["lanes"][0].lane_state,
        registered_on: registration["created_at"],
        comment: registration["lanes"][0].step_details["comment"],
      }, status: 'ok' }
    rescue Dynamoid::Errors::RecordNotFound
      render json: { registration: {}, status: 'ok' }
    end
  end

  def delete
    user_id = params[:competitor_id]
    competition_id = params[:competition_id]

    unless validate_request(user_id, competition_id)
      Metrics.registration_validation_errors_counter.increment
      return render json: { status: 'User cannot register, wrong format' }, status: :forbidden
    end
    begin
      registration = Registrations.find("#{competition_id}-#{user_id}")
      updated_lanes = registration.lanes.map { |lane|
        if lane.name == "Competing"
          lane.lane_state = "deleted"
        end
        lane
      }
      puts updated_lanes.to_json
      registration.update_attributes(lanes: updated_lanes)
      # Render a success response
      render json: { status: 'ok' }
    rescue StandardError => e
      # Render an error response
      puts e
      Metrics.registration_dynamodb_errors_counter.increment
      render json: { status: "Error deleting item from DynamoDB: #{e.message}" },
             status: :internal_server_error
    end
  end

  def list
    competition_id = params[:competition_id]
    registrations = get_registrations(competition_id, only_attending: true)

    # Render a success response
    render json: registrations
  rescue StandardError => e
    # Render an error response
    puts e
    Metrics.registration_dynamodb_errors_counter.increment
    render json: { status: "Error getting registrations" },
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
    render json: { status: "Error getting registrations" },
           status: :internal_server_error
  end

  private

    REGISTRATION_STATUS = %w[waiting accepted deleted].freeze

    def user_exists(competitor_id)
      Rails.cache.fetch(competitor_id, expires_in: 12.hours) do
        CompetitorApi.check_competitor(competitor_id)
      end
    end

    def competition_open(competition_id)
      Rails.cache.fetch(competition_id, expires_in: 5.minutes) do
        CompetitionApi.check_competition(competition_id)
      end
    end

    def can_user_register?(competitor_id, competition_id)
      # Check if user exists
      user_exists(competitor_id) and competition_open(competition_id)
    end

    def validate_request(competitor_id, competition_id, status = 'waiting')
      if competitor_id.present? && competitor_id.to_s =~ (/\A\d+\z/)
        if competition_id =~ (/^[a-zA-Z]+\d{4}$/) && REGISTRATION_STATUS.include?(status)
          can_user_register?(competitor_id, competition_id)
        end
      else
        false
      end
    end

    def get_registrations(competition_id, only_attending: false)
      # Query DynamoDB for registrations with the given competition_id using the Global Secondary Index
      # TODO make this more beautiful and not break if there are more then one lane
      # This also currently breaks if a registration is started but never completed
      if only_attending
        Registrations.where(competition_id: competition_id, is_attending: true).all.map do |x|
          { competitor_id: x["user_id"],
            event_ids: x["lanes"][0].step_details["event_ids"] }
        end
      else
        Registrations.where(competition_id: competition_id).all.map do |x|
          { competitor_id: x["user_id"],
            event_ids: x["lanes"][0].step_details["event_ids"],
            registration_status: x["lanes"][0].lane_state,
            registered_on: x["created_at"],
            comment: x["lanes"][0].step_details["comment"] }
        end
      end
    end
end
