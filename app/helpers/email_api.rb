# frozen_string_literal: true

require 'httparty'
require 'json'
require_relative 'mocks'
require_relative 'wca_api'

def registration_email_path
  "https://#{EnvConfig.WCA_HOST}/api/internal/v1/mailer/registration"
end

class EmailApi < WcaApi
  def self.send_update_email(competition_id, user_id, status)
    HTTParty.post(registration_email_path, headers: { WCA_API_HEADER => self.get_wca_token }, body: { competition_id: competition_id, user_id: user_id, status: status, action: 'update' })
  end

  def self.send_creation_email(competition_id, user_id)
    HTTParty.post(registration_email_path, headers: { WCA_API_HEADER => self.get_wca_token }, body: { competition_id: competition_id, user_id: user_id, status: 'pending', action: 'create' })
  end
end
