# frozen_string_literal: true

class RegistrationProcessor < ApplicationJob
  include Shoryuken::Worker

  queue_as EnvConfig.QUEUE_NAME

  def perform(message)
    Rails.logger.debug { "Working on Message: #{message}" }
    side_effects = JobSideEffects.new
    if message[:step] == 'EventRegistration'
      event_registration(message[:competition_id],
                         message[:user_id],
                         message[:step_details][:event_ids],
                         message[:step_details][:comment],
                         message[:step_details][:guests],
                         message[:created_at],
                         side_effects)
    end
    side_effects.run(:after_processing)
    Metrics.increment('registrations_processed')
  end

  private

    # rubocop:disable Metrics/ParameterLists
    def event_registration(competition_id, user_id, event_ids, comment, guests, created_at, side_effects)
      # Event Registration might not be the first lane that is completed
      # TODO: When we add another lane, we need to update the registration history instead of creating it
      begin
        registration = V2Registration.find_by(competition_id: competition_id, user_id: user_id)
        if registration.nil?
          registration = V2Registration.create(competition_id: competition_id,
                                            user_id: user_id,
                                            created_at: created_at)
          initial_history = registration.registration_history_entry.create(actor_type: 'user', actor_id: user_id, action: 'Worker processed', timestamp: created_at)
          [:event_ids, :comment, :guests, :status].each do |key|
            initial_history.registration_history_change.create(from: "", to: "", key: key.to_s)
          end
          # { 'changed_attributes' =>
          #     { event_ids: event_ids, comment: comment, guests: guests, status: 'pending' }
        end
        registration.registration_lane.create(LaneFactory.competing_lane(event_ids: event_ids, comment: comment))
        side_effects.after_processing do
          EmailApi.send_creation_email(competition_id, user_id)
        end
      rescue Exception => exception
        puts("Error #{exception}")
        puts(exception.backtrace)
      end
    end
  # rubocop:enable Metrics/ParameterLists
end
