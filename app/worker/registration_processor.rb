# frozen_string_literal: true

require 'aws-sdk-dynamodb'
require 'dynamoid'
require 'httparty'
require_relative '../helpers/lane_factory'
require_relative '../helpers/jwt_helper'

class RegistrationProcessor
  def initialize
    Dynamoid.configure do |config|
      config.region = ENV.fetch("AWS_REGION", 'us-west-2')
      config.namespace = nil
      if ENV.fetch("CODE_ENVIRONMENT", "development") == "development"
        config.endpoint = ENV.fetch('LOCALSTACK_ENDPOINT', nil)
      else
        config.credentials = Aws::ECSCredentials.new(retries: 3)
      end
    end
    # We have to require the model after we initialized dynamoid
    require_relative '../models/registration'
  end

  def process_message(message)
    puts "Working on Message: #{message}"
    if message['step'] == 'Lane Init'
      lane_init(message['competition_id'], message['user_id'])
    elsif message['step'] == 'Payment init'
      payment_init(message['attendee_id'],
                   message['step_details']['fee_lowest_denomination'],
                   message['step_details']['currency_code'])
    elsif message['step'] == 'Event Registration'
      event_registration(message['competition_id'],
                         message['user_id'],
                         message['step_details']['event_ids'],
                         message['step_details']['comment'],
                         message['step_details']['guests'])
    end
  end

  private

    def lane_init(competition_id, user_id)
      empty_registration = Registration.new(attendee_id: "#{competition_id}-#{user_id}",
                                            competition_id: competition_id,
                                            user_id: user_id, lane_states:[{ "competing": "initialized" }])
      empty_registration.save!
    end

    def payment_init(attendee_id, fee_lowest_denomination, currency_code)
      token = JwtHelper.get_token("payments.worldcubeassociation.org")
      response = HTTParty.post("https://test-registration.worldcubeassociation.org/api/v10/internal/payments/init", body: { "attendee_id" => attendee_id }.to_json, headers: { 'Authorization' => "Bearer: #{token}", "Content-Type" => "application/json" })
      unless response.ok?
        raise "Error from the payments service" # This will retry the query item
      end
      registration = Registration.find(attendee_id)
      payment_lane = LaneFactory.payment_lane(fee_lowest_denomination, currency_code, response["payment_intent_id"])
      payment_lane_state = { "payment": "initialized" }
      # Due to the nature of using a FIFO queue, event_registration should have completed already, should we still
      # check for registration.lanes.nil? as in event_registration?
      registration.update_attributes(lanes: registration.lanes.append(payment_lane), lane_states: registration.lane_states.append(payment_lane_state))
    end

    def event_registration(competition_id, user_id, event_ids, comment, guests)
      registration = Registration.find("#{competition_id}-#{user_id}")
      competing_lane = LaneFactory.competing_lane(event_ids, comment, guests)
      competing_lane_state = { "competing": "incoming" }
      if registration.lanes.nil?
        registration.update_attributes(lanes: [competing_lane], lane_states: [competing_lane_state])
      else
        registration.update_attributes(lanes: registration.lanes.append(competing_lane), lane_states: registration.lane_states.append(competing_lane_state))
      end
    end
end
