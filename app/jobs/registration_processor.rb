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
                         message[:created_at],
                         message[:step_details],
                         side_effects)
    end
    side_effects.run(:after_processing)
    Metrics.increment('registrations_processed')
  end

  private

    # rubocop:disable Metrics/ParameterLists
    def event_registration(competition_id, user_id, created_at, registration_params, side_effects)
      #registration_params = event_ids, comment, guests
      # Event Registration might not be the first lane that is completed
      # TODO: When we add another lane, we need to update the registration history instead of creating it
      registration = V2Registration.find_by(competition_id: competition_id, user_id: user_id)
      ActiveRecord::Base.transaction do
        if registration.nil?
          registration = V2Registration.create(competition_id: competition_id, user_id: user_id, created_at: created_at, guests: registration_params[:guests])
          registration.add_history_entry(RegistrationHelper.update_changes(registration_params, {}), 'user', user_id, 'Worker processed', created_at)
        end
        registration.registration_lane.create(LaneFactory.competing_lane(event_ids: registration_params[:event_ids], comment: registration_params[:comment]))
      end
      side_effects.after_processing do
        EmailApi.send_creation_email(competition_id, user_id)
      end
    end
  # rubocop:enable Metrics/ParameterLists
end
