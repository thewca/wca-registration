# frozen_string_literal: true

require 'httparty'
require 'json'

class EmailApi < WcaApi
  def registration_email_path
    "#{EnvConfig.WCA_HOST}/api/internal/v1/mailers/registration"
  end

  def self.send_update_email(competition_id, user_id, status, current_user)
    HTTParty.post(EmailApi.registration_email_path, headers: { WCA_API_HEADER => self.wca_token }, body: { competition_id: competition_id, user_id: user_id, status: status, action: 'update', current_user: current_user })
  end

  def self.send_creation_email(competition_id, user_id)
    HTTParty.post(EmailApi.registration_email_path, headers: { WCA_API_HEADER => self.wca_token }, body: { competition_id: competition_id, user_id: user_id, status: 'pending', action: 'create', current_user: user_id })
  end
end
