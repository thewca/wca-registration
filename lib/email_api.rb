# frozen_string_literal: true

require 'httparty'
require 'json'

class EmailApi < WcaApi
  def self.registration_email_path
    "#{EnvConfig.WCA_HOST}/api/internal/v1/mailers/registration"
  end

  def self.send_update_email(competition_id, user_id, status, current_user)
    self.post_request(
      EmailApi.registration_email_path,
      { competition_id: competition_id,
        user_id: user_id,
        registration_status: status,
        registration_action: 'update',
        current_user: current_user }.to_json,
    )
  end

  def self.send_creation_email(competition_id, user_id)
    self.post_request(
      EmailApi.registration_email_path,
      {
        competition_id: competition_id,
        user_id: user_id,
        registration_status: 'pending',
        registration_action: 'create',
        current_user: user_id,
      }.to_json,
    )
  end
end
