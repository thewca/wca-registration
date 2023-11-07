# frozen_string_literal: true

COMMENT_CHARACTER_LIMIT = 240

class RegistrationChecker
  def self.create_registration_allowed!(registration_request, competition_info, requesting_user)
    @registration_request = registration_request
    @competition_info = competition_info
    @requester_user_id = requesting_user

    user_can_create_registration!
    validate_events!
    validate_guests!
    validate_comment!
    # TODO: Should we allow admin comments upon registration? Check my slack convo w/ Finn
    true
  end

  class << self
    def user_can_create_registration!
      puts 'here'
      puts @registration_request[:user_id]
      puts "requester id: #{@requester_user_id}"
      # Only an admin or the user themselves can create a registration for the user
      raise RegistrationError.new(:unauthorized, ErrorCodes::USER_INSUFFICIENT_PERMISSIONS) unless is_admin_or_current_user?

      # Only admins can register when registration is closed, and they can only register for themselves - not for other users
      raise RegistrationError.new(:forbidden, ErrorCodes::REGISTRATION_CLOSED) unless @competition_info.registration_open? || admin_modifying_own_registration?

      can_compete = UserApi.can_compete?(@registration_request[:user_id])
      raise RegistrationError.new(:unauthorized, ErrorCodes::USER_CANNOT_COMPETE) unless can_compete

      can_compete
    end

    def user_can_modify_registration!
      raise RegistrationError.new(:unauthorized, ErrorCodes::USER_INSUFFICIENT_PERMISSIONS) unless is_admin_or_current_user?
      raise RegistrationError.new(:unauthorized, ErrorCodes::USER_INSUFFICIENT_PERMISSIONS) unless @competition_info.registration_edits_allowed?
    end

    def admin_modifying_own_registration?
      UserApi.can_administer?(@requester_user_id, @competition_id) && (@requester_user_id == @registration_request[:user_id].to_s)
    end

    def is_admin_or_current_user?
      defined?(@registration) ? request = @update_request : request = @registration_request
      # Only an admin or the user themselves can create a registration for the user
      # One case where admins need to create registrations for users is if a 3rd-party registration system is being used, and registration data is being
      # passed to the Registration Service from it
      (@requester_user_id == request[:user_id].to_s) || UserApi.can_administer?(@requester_user_id, @competition_id)
    end

    def validate_events!
      if defined?(@registration) && update_request['competing'].key?(:status) && update_request['competing'][:status] == 'cancelled'
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
      # raise RegistrationError.new(:forbidden, ErrorCodes::EDIT_DEADLINE_PASSED) if events_edit_deadline < Time.now
    end

    def validate_guests!
      defined?(@registration) ? request = @update_request : request = @registration_request

      return true unless request.key?(:guests)

      raise RegistrationError.new(:unprocessable_entity, ErrorCodes::INVALID_REQUEST_DATA) if request[:guests] < 0
      raise RegistrationError.new(:unprocessable_entity, ErrorCodes::GUEST_LIMIT_EXCEEDED) if @competition_info.guest_limit_exceeded?(request[:guests])
      raise RegistrationError.new(:forbidden, ErrorCodes::EDIT_DEADLINE_PASSED) if
      defined?(@registration) && @competition_info.within_event_change_deadline? && !UserApi.can_administer?(@requester_user_id, @competition_id)
    end

    def validate_comment!
      defined?(@registration) ? request = @update_request : request = @registration_request
      if request.key?(:competing) && request[:competing].key?(:comment)
        comment = request[:competing][:comment]

        raise RegistrationError.new(:unprocessable_entity, ErrorCodes::USER_COMMENT_TOO_LONG) if comment.length > COMMENT_CHARACTER_LIMIT
        raise RegistrationError.new(:unprocessable_entity, ErrorCodes::REQUIRED_COMMENT_MISSING) if @competition_info.force_comment? && comment == ''
        raise RegistrationError.new(:forbidden, ErrorCodes::REGISTRATION_CLOSED) unless @competition_info.within_event_change_deadline?
      else
        raise RegistrationError.new(:unprocessable_entity, ErrorCodes::REQUIRED_COMMENT_MISSING) if @competition_info.force_comment?
      end
      true
    end
  end
end
