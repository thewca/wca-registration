# frozen_string_literal: true

require 'aws-sdk-dynamodb'
require 'dynamoid'
require_relative '../helpers/lane_factory'

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
    require_relative '../models/registrations'
  end

  def process_message(message)
    puts "Working on Message: #{message}"
    if message['step'] == 'Lane Init'
      lane_init(message['competition_id'], message['user_id'])
    elsif message['step'] == 'Event Registration'
      event_registration(message['competition_id'], message['user_id'], message['step_details']['event_ids'])
    end
  end

  private

    def lane_init(competition_id, user_id)
      empty_registration = Registrations.new(attendee_id: "#{competition_id}-#{user_id}", competition_id: competition_id, user_id: user_id)
      empty_registration.save!
    end

    def event_registration(competition_id, user_id, event_ids)
      registration = Registrations.find("#{competition_id}-#{user_id}")
      competing_lane = LaneFactory.competing_lane(event_ids)
      if registration.lanes.nil?
        registration.update_attributes(lanes: [competing_lane])
      else
        registration.update_attributes(lanes: registration.lanes.append(competing_lane))
      end
      registration.save!
    end
end
