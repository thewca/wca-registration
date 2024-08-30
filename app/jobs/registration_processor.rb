# frozen_string_literal: true

class RegistrationProcessor < ApplicationJob
  include Shoryuken::Worker

  queue_as EnvConfig.QUEUE_NAME

  def perform(message)
    Rails.logger.debug { "Working on Message: #{message}" }
    if message[:step] == 'EventRegistration'
      event_registration(message[:competition_id],
                         message[:user_id],
                         message[:step_details][:event_ids],
                         message[:step_details][:comment],
                         message[:step_details][:guests],
                         message[:created_at])
    end

    # Invalidate Cache
    Rails.cache.delete("#{message[:user_id]}-registrations-by-user")
  end

  private

    # rubocop:disable Metrics/ParameterLists
    def event_registration(competition_id, user_id, event_ids, comment, guests, created_at)
      # Event Registration might not be the first lane that is completed
      # TODO: When we add another lane, we need to update the registration history instead of creating it
      registration = begin
        Registration.find("#{competition_id}-#{user_id}")
      rescue Dynamoid::Errors::RecordNotFound
        initial_history = History.new({ 'changed_attributes' =>
                                          { event_ids: event_ids, comment: comment, guests: guests, status: 'pending' },
                                        'actor_type' => 'user',
                                        'actor_id' => user_id,
                                        'action' => 'Worker processed',
                                        'timestamp' => created_at })
        RegistrationHistory.create(attendee_id: "#{competition_id}-#{user_id}", entries: [initial_history])
        Registration.new(attendee_id: "#{competition_id}-#{user_id}",
                         competition_id: competition_id,
                         user_id: user_id,
                         created_at: created_at)
      end
      competing_lane = LaneFactory.competing_lane(event_ids: event_ids, comment: comment)
      if registration.lanes.nil?
        registration.update_attributes(lanes: [competing_lane], guests: guests)
      else
        registration.update_attributes(lanes: registration.lanes.append(competing_lane), guests: guests)
      end
      EmailApi.send_creation_email(competition_id, user_id)
    end
  # rubocop:enable Metrics/ParameterLists
end
