# frozen_string_literal: true

require 'aws-sdk-dynamodb'
require 'dynamoid'
require 'httparty'
require_relative '../helpers/wca_api'
require_relative '../helpers/lane_factory'
require_relative 'env_config'

class RegistrationProcessor
  def initialize
    Dynamoid.configure do |config|
      config.region = EnvConfig.AWS_REGION
      config.namespace = nil
      if EnvConfig.CODE_ENVIRONMENT == 'development'
        config.endpoint = EnvConfig.LOCALSTACK_ENDPOINT
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
                                            user_id: user_id)
      RegistrationHistory.create(attendee_id: "#{competition_id}-#{user_id}")
      empty_registration.save!
    end

    def event_registration(competition_id, user_id, event_ids, comment, guests)
      registration = Registration.find("#{competition_id}-#{user_id}")
      competing_lane = LaneFactory.competing_lane(event_ids: event_ids, comment: comment)
      if registration.lanes.nil?
        registration.update_attributes(lanes: [competing_lane], guests: guests)
      else
        registration.update_attributes(lanes: registration.lanes.append(competing_lane), guests: guests)
      end
      if EnvConfig.CODE_ENVIRONMENT == 'production'
        EmailApi.send_creation_email(competition_id, user_id)
      end
    end
end
