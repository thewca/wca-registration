# frozen_string_literal: true

require 'securerandom'
require_relative '../helpers/competition_api'
require_relative '../helpers/competitor_api'

class RegistrationController < ApplicationController
  before_action :ensure_lane_exists, only: [:create]

  # We don't know which lane the user is going to complete first, this ensures that an entry in the DB exists
  # regardless of which lane the uses chooses to start with
  def ensure_lane_exists
    user_id = params[:competitor_id]
    competition_id = params[:competition_id]
    @queue_url = ENV["QUEUE_URL"] || $sqs.get_queue_url(queue_name: 'registrations.fifo').queue_url
    # TODO: Cache this call? We could keep a list of already created keys
    lane_created = begin
      Registration.find("#{competition_id}-#{user_id}")
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
      lane_name: 'competing',
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
    unless validate_request(user_id, competition_id)
      Metrics.registration_validation_errors_counter.increment
      return render json: { status: "Can't get registration, wrong format" }, status: :forbidden
    end
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
