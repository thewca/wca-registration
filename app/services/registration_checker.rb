# frozen_string_literal: true

class RegistrationChecker
  def self.create_registration_allowed!(registration, competition, current_user)
    @registration_request = registration
    @competition_info = competition
    @requester_user_id = current_user

    user_can_create_registration!
    validate_events!
  end

  class << self
    def user_can_create_registration!
      # Only an admin or the user themselves can create a registration for the user
      raise RegistrationError.new(:unauthorized, ErrorCodes::USER_INSUFFICIENT_PERMISSIONS) unless is_admin_or_current_user?

      # Only admins can register when registration is closed, and they can only register for themselves - not for other users
      raise RegistrationError.new(:forbidden, ErrorCodes::REGISTRATION_CLOSED) unless @competition_info.registration_open? || admin_modifying_own_registration?

      can_compete, reasons = UserApi.can_compete?(@registration_request[:user_id])
      raise RegistrationError.new(:unauthorized, reasons) unless can_compete

      can_compete
    end

    def admin_modifying_own_registration?
      UserApi.can_administer?(@requester_user_id, @competition_id) && (@requester_user_id == @registration_request[:user_id].to_s)
    end

    def is_admin_or_current_user?
      # Only an admin or the user themselves can create a registration for the user
      # One case where admins need to create registrations for users is if a 3rd-party registration system is being used, and registration data is being
      # passed to the Registration Service from it
      (@requester_user_id == @registration_request[:user_id].to_s) || UserApi.can_administer?(@requester_user_id, @competition_id)
    end

    def validate_events!
      if defined?(@registration) && params['competing'].key?(:status) && params['competing'][:status] == 'cancelled'
      # If status is cancelled, events can only be empty or match the old events list
      # This allows for edge cases where an API user might send an empty event list/the old event list, or admin might want to remove events
      # event_ids = params['competing'][:event_ids]
      # raise RegistrationError.new(:unprocessable_entity, ErrorCodes::INVALID_EVENT_SELECTION) unless event_ids == [] || event_ids == @registration_request.event_ids
      else
        event_ids = @registration_request[:competing][:event_ids]
        # Event submitted must be held at the competition
        raise RegistrationError.new(:unprocessable_entity, ErrorCodes::INVALID_EVENT_SELECTION) unless @competition_info.events_held?(event_ids)
      end

      # Events can't be changed outside the edit_events deadline, except by admins
      # TODO: Allow an admin to edit past the deadline
      # events_edit_deadline = Time.parse(@competition_info.event_change_deadline)
      # raise RegistrationError.new(:forbidden, ErrorCodes::EVENT_EDIT_DEADLINE_PASSED) if events_edit_deadline < Time.now

      true
    end
  end
end
