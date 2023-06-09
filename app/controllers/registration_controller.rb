# frozen_string_literal: true

require 'securerandom'
require_relative '../helpers/competition_api'
require_relative '../helpers/competitor_api'

class RegistrationController < ApplicationController
  def create
    competitor_id = params[:competitor_id]
    competition_id = params[:competition_id]
    event_ids = params[:event_ids]

    unless validate_request(competitor_id, competition_id) && !event_ids.empty?
      Metrics.registration_validation_errors_counter.increment
      return render json: { status: 'User cannot register for competition' }, status: :forbidden
    end

    id = SecureRandom.uuid

    step_data = {
      competitor_id: competitor_id,
      competition_id: competition_id,
      event_ids: event_ids,
      registration_status: 'waiting',
      step: 'Event Registration',
    }
    queue_url = ENV["QUEUE_URL"] || @sqs.get_queue_url(queue_name: 'registrations.fifo').queue_url

    $sqs.send_message({
                        queue_url: queue_url,
                        message_body: step_data.to_json,
                        message_group_id: id,
                        message_deduplication_id: id,
                      })

    render json: { status: 'ok', message: 'Started Registration Process' }
  end

  def update
    competitor_id = params[:competitor_id]
    competition_id = params[:competition_id]
    status = params[:status]

    unless validate_request(competitor_id, competition_id, status)
      Metrics.registration_validation_errors_counter.increment
      return render json: { status: 'User cannot register, wrong format' }, status: :forbidden
    end

    # Specify the key attributes for the item to be updated
    key = {
      'competitor_id' => competitor_id,
      'competition_id' => competition_id,
    }

    # Set the expression for the update operation
    update_expression = 'set registration_status = :s'
    expression_attribute_values = {
      ':s' => status,
    }

    begin
      # Update the item in the table
      $dynamodb.update_item({
                              table_name: 'Registrations',
                              key: key,
                              update_expression: update_expression,
                              expression_attribute_values: expression_attribute_values,
                            })
      render json: { status: 'ok' }
    rescue Aws::DynamoDB::Errors::ServiceError => e
      puts e
      Metrics.registration_dynamodb_errors_counter.increment
      render json: { status: 'Failed to update registration data' }, status: :internal_server_error
    end
  end

  def delete
    competitor_id = params[:competitor_id]
    competition_id = params[:competition_id]

    unless validate_request(competitor_id, competition_id)
      Metrics.registration_validation_errors_counter.increment
      return render json: { status: 'User cannot register, wrong format' }, status: :forbidden
    end

    # Define the key of the item to delete
    key = {
      'competition_id' => competition_id,
      'competitor_id' => competitor_id,
    }

    begin
      # Call the delete_item method to delete the item from the table
      $dynamodb.delete_item(
        table_name: 'Registrations',
        key: key,
      )

      # Render a success response
      render json: { status: 'ok' }
    rescue Aws::DynamoDB::Errors::ServiceError => e
      # Render an error response
      puts e
      Metrics.registration_dynamodb_errors_counter.increment
      render json: { status: "Error deleting item from DynamoDB: #{e.message}" },
             status: :internal_server_error
    end
  end

  def list
    competition_id = params[:competition_id]
    registrations = get_registrations(competition_id)
    # Render a success response
    render json: registrations
  rescue Aws::DynamoDB::Errors::ServiceError => e
    # Render an error response
    puts e
    Metrics.registration_dynamodb_errors_counter.increment
    render json: { status: "Error getting registrations" },
           status: :internal_server_error
  end

  private

    REGISTRATION_STATUS = %w[waiting accepted].freeze

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
      if competitor_id.present? && competitor_id =~ (/^\d{4}[a-zA-Z]{4}\d{2}$/)
        if competition_id =~ (/^[a-zA-Z]+\d{4}$/) && REGISTRATION_STATUS.include?(status)
          can_user_register?(competitor_id, competition_id)
        end
      else
        false
      end
    end

    def get_registrations(competition_id)
      # Query DynamoDB for registrations with the given competition_id
      resp = $dynamodb.query({
                               table_name: 'Registrations',
                               key_condition_expression: '#ci = :cid',
                               expression_attribute_names: { '#ci' => 'competition_id' },
                               expression_attribute_values: { ':cid' => competition_id },
                             })

      # Return the items from the response
      resp.items
    end
end
