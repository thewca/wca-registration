# frozen_string_literal: true

require 'httparty'
require 'json'

class EmailApi < WcaApi
  def self.registration_email_path
    "#{EnvConfig.WCA_HOST}/api/internal/v1/mailers/registration"
  end

  def self.waiting_list_leader_path
    "#{EnvConfig.WCA_HOST}/api/internal/v1/mailers/waiting-list-leader"
  end

  def self.send_update_email(competition_id, user_id, status, current_user)
    HTTParty.post(EmailApi.registration_email_path, headers: { WCA_API_HEADER => self.wca_token }, body: {
                    competition_id: competition_id,
                    user_id: user_id,
                    registration_status: status,
                    registration_action: 'update',
                    current_user: current_user,
                  })
  end

  def self.send_creation_email(competition_id, user_id)
    HTTParty.post(EmailApi.registration_email_path, headers: { WCA_API_HEADER => self.wca_token }, body: {
                    competition_id: competition_id,
                    user_id: user_id,
                    registration_status: 'pending',
                    registration_action: 'create',
                    current_user: user_id,
                  })
  end

  def self.send_waiting_list_leader_email(competition_id, user_id, position)
    HTTParty.post(EmailApi.waiting_list_leader_path, headers: { WCA_API_HEADER => self.wca_token }, body: {
                    competition_id: competition_id,
                    user_id: user_id,
                    position: position,
                  })

  end
end
