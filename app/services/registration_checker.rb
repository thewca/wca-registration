# frozen_string_literal: true

COMMENT_CHARACTER_LIMIT = 240

class RegistrationChecker
  def self.create_registration_allowed!(registration_request, competition_info, requesting_user)
    @request = registration_request
    @competition_info = competition_info
    @requester_user_id = requesting_user

    user_can_create_registration!
    validate_create_events!
    validate_guests!
    validate_comment!
    true
  end

  def self.update_registration_allowed!(update_request, competition_info, requesting_user)
    @request = update_request
    @competition_info = competition_info
    @requester_user_id = requesting_user
    @registration = Registration.find("#{update_request['competition_id']}-#{update_request['user_id']}")

    user_can_modify_registration!
    validate_guests!
    validate_comment!
    validate_admin_fields!
    validate_admin_comment!
    validate_update_status!
    validate_update_events!
  end

  class << self
    def user_can_create_registration!
      # Only an admin or the user themselves can create a registration for the user
      raise RegistrationError.new(:unauthorized, ErrorCodes::USER_INSUFFICIENT_PERMISSIONS) unless is_admin_or_current_user?

      # Only admins can register when registration is closed, and they can only register for themselves - not for other users
      raise RegistrationError.new(:forbidden, ErrorCodes::REGISTRATION_CLOSED) unless @competition_info.registration_open? || organizer_modifying_own_registration?

      can_compete = UserApi.can_compete?(@request['user_id'])
      raise RegistrationError.new(:unauthorized, ErrorCodes::USER_CANNOT_COMPETE) unless can_compete

      can_compete
    end

    def user_can_modify_registration!
      raise RegistrationError.new(:unauthorized, ErrorCodes::USER_INSUFFICIENT_PERMISSIONS) unless is_admin_or_current_user?
      raise RegistrationError.new(:forbidden, ErrorCodes::USER_EDITS_NOT_ALLOWED) unless @competition_info.registration_edits_allowed? || user_is_admin?
    end

    def organizer_modifying_own_registration?
      UserApi.can_administer?(@requester_user_id, @competition_info.competition_id) && (@requester_user_id == @request['user_id'].to_s)
    end

    def is_admin_or_current_user?
      # Only an admin or the user themselves can create a registration for the user
      # One case where admins need to create registrations for users is if a 3rd-party registration system is being used, and registration data is being
      # passed to the Registration Service from it
      (@requester_user_id == @request['user_id'].to_s) || user_is_admin?
    end

    def user_is_admin?
      UserApi.can_administer?(@requester_user_id, @competition_info.competition_id)
    end

    def validate_create_events!
      event_ids = @request['competing']['event_ids']
      # Event submitted must be held at the competition
      raise RegistrationError.new(:unprocessable_entity, ErrorCodes::INVALID_EVENT_SELECTION) unless @competition_info.events_held?(event_ids)
    end

    def validate_events!
      # if @registration.present? && update_request['competing'].key?('status') && update_request['competing']['status'] == 'cancelled'
      # If status is cancelled, events can only be empty or match the old events list
      # This allows for edge cases where an API user might send an empty event list/the old event list, or admin might want to remove events
      # event_ids = params['competing']['event_ids']
      # raise RegistrationError.new(:unprocessable_entity, ErrorCodes::INVALID_EVENT_SELECTION) unless event_ids == [] || event_ids == @registration_request.event_ids
      # end

      # Events can't be changed outside the edit_events deadline, except by admins
      # TODO: Allow an admin to edit past the deadline
      # events_edit_deadline = Time.parse(@competition_info.event_change_deadline)
      # raise RegistrationError.new(:forbidden, ErrorCodes::EDIT_DEADLINE_PASSED) if events_edit_deadline < Time.now
    end

    def validate_guests!
      return unless @request.key?('guests')

      raise RegistrationError.new(:unprocessable_entity, ErrorCodes::INVALID_REQUEST_DATA) if @request['guests'] < 0
      raise RegistrationError.new(:unprocessable_entity, ErrorCodes::GUEST_LIMIT_EXCEEDED) if @competition_info.guest_limit_exceeded?(@request['guests'])
    end

    def validate_comment!
      if @request.key?('competing') && @request['competing'].key?('comment')
        comment = @request['competing']['comment']

        raise RegistrationError.new(:unprocessable_entity, ErrorCodes::USER_COMMENT_TOO_LONG) if comment.length > COMMENT_CHARACTER_LIMIT
        raise RegistrationError.new(:unprocessable_entity, ErrorCodes::REQUIRED_COMMENT_MISSING) if @competition_info.force_comment? && comment == ''
      else
        raise RegistrationError.new(:unprocessable_entity, ErrorCodes::REQUIRED_COMMENT_MISSING) if @competition_info.force_comment?
      end
    end

    def validate_admin_fields!
      @admin_fields = ['admin_comment']

      raise RegistrationError.new(:unauthorized, ErrorCodes::USER_INSUFFICIENT_PERMISSIONS) if contains_admin_fields? && !UserApi.can_administer?(@requester_user_id, @competition_info.competition_id)
    end

    def validate_admin_comment!
      if @request.key?('competing') && @request['competing'].key?('admin_comment')
        admin_comment = @request['competing']['admin_comment']

        raise RegistrationError.new(:unprocessable_entity, ErrorCodes::USER_COMMENT_TOO_LONG) if admin_comment.length > COMMENT_CHARACTER_LIMIT
      end
    end

    def contains_admin_fields?
      @request.key?('competing') && @request['competing'].keys.any? { |key| @admin_fields.include?(key) }
    end

    def validate_update_status!
      return unless @request.key?('competing') && @request['competing'].key?('status')

      old_status = @registration.competing_status
      new_status = @request['competing']['status']

      raise RegistrationError.new(:unprocessable_entity, ErrorCodes::INVALID_REQUEST_DATA) unless Registration::REGISTRATION_STATES.include?(new_status)
      raise RegistrationError.new(:forbidden, ErrorCodes::COMPETITOR_LIMIT_REACHED) if
        new_status == 'accepted' && Registration.accepted_competitors >= @competition_info.competitor_limit

      unless user_is_admin?
        if new_status == 'pending'
          raise RegistrationError.new(:unauthorized, ErrorCodes::USER_INSUFFICIENT_PERMISSIONS) unless old_status == 'cancelled'
        elsif new_status == 'cancelled'
          raise RegistrationError.new(:unauthorized, ErrorCodes::ORGANIZER_MUST_CANCEL_REGISTRATION) if
            !@competition_info.user_can_cancel? && @registration.competing_status == 'accepted'
          raise RegistrationError.new(:unprocessable_entity, ErrorCodes::INVALID_REQUEST_DATA) if
            @request['competing'].key?('event_ids') && @registration.event_ids != @request['competing']['event_ids']
        else
          raise RegistrationError.new(:unauthorized, ErrorCodes::USER_INSUFFICIENT_PERMISSIONS)
        end
      end
    end

    def validate_update_events!
      return unless @request.key?('competing') && @request['competing'].key?('event_ids')
      raise RegistrationError.new(:unprocessable_entity, ErrorCodes::INVALID_EVENT_SELECTION) if !@competition_info.events_held?(
        @request['competing']['event_ids'],
      )
    end
  end
end
