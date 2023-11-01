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

  def self.update_registration_allowed!(update_request, competition_info, requesting_user)
    @update_request = update_request
    @competition_info = competition_info
    @requester_user_id = requesting_user
    @registration = Registration.find("#{update_request[:competition_id]}-#{update_request[:user_id]}")

    user_can_modify_registration!
    validate_comment!
    validate_admin_fields!
    validate_admin_comment!
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

    def user_can_modify_registration!
      raise RegistrationError.new(:unauthorized, ErrorCodes::USER_INSUFFICIENT_PERMISSIONS) unless is_admin_or_current_user?
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
      # raise RegistrationError.new(:forbidden, ErrorCodes::EVENT_EDIT_DEADLINE_PASSED) if events_edit_deadline < Time.now
    end

    def validate_guests!
      defined?(@registration) ? request = @update_request : request = @registration_request
      raise RegistrationError.new(:unprocessable_entity, ErrorCodes::INVALID_REQUEST_DATA) if request.key?(:guests) && request[:guests] < 0
      raise RegistrationError.new(:unprocessable_entity, ErrorCodes::GUEST_LIMIT_EXCEEDED) if request.key?(:guests) && @competition_info.guest_limit_exceeded?(request[:guests])
    end

    def validate_comment!
      defined?(@registration) ? request = @update_request : request = @registration_request
      if request.key?(:competing) && request[:competing].key?(:comment)
        comment = request[:competing][:comment]
        puts comment
        puts comment.length

        raise RegistrationError.new(:unprocessable_entity, ErrorCodes::USER_COMMENT_TOO_LONG) if comment.length > COMMENT_CHARACTER_LIMIT
        raise RegistrationError.new(:unprocessable_entity, ErrorCodes::REQUIRED_COMMENT_MISSING) if @competition_info.force_comment? && comment == ''
        puts 1
      else
        raise RegistrationError.new(:unprocessable_entity, ErrorCodes::REQUIRED_COMMENT_MISSING) if @competition_info.force_comment?
        puts 2
      end
      true
    end

    def validate_admin_fields!
      @admin_fields = [:admin_comment]

      puts contains_admin_fields?
      puts !UserApi.can_administer?(@current_user, @competition_id)
      raise RegistrationError.new(:unauthorized, ErrorCodes::USER_INSUFFICIENT_PERMISSIONS) if contains_admin_fields? && !UserApi.can_administer?(@requester_user_id, @competition_info.competition_id)
      true
    end

    def validate_admin_comment!
      if @update_request.key?(:competing) && @update_request[:competing].key?(:admin_comment)
        admin_comment = @update_request[:competing][:admin_comment]

        raise RegistrationError.new(:unprocessable_entity, ErrorCodes::USER_COMMENT_TOO_LONG) if admin_comment.length > COMMENT_CHARACTER_LIMIT
      end
      true
    end

    def contains_admin_fields?
      @update_request.key?(:competing) && @update_request[:competing].keys.any? { |key| @admin_fields.include?(key) }
    end
  end
end
