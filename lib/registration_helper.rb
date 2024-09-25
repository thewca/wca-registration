module RegistrationHelper
  REGISTRATION_STATES = %w[pending waiting_list accepted cancelled rejected].freeze
  ADMIN_ONLY_STATES = %w[pending waiting_list accepted rejected].freeze # Only admins are allowed to change registration state to one of these states
  MIGHT_ATTEND_STATES = %w[pending waiting_list accepted].freeze
  def self.update_changes(update_request, registration)
    changes = {}

    update_request.each do |key, value|
      changes[key.to_sym] = { from: registration[key], to: value} if value.present?
    end

    changes[:guests] = { from: registration[:guests], to: update_request[:guests] } if update_request[:guests].present?
    changes
  end
end
