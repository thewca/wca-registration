# frozen_string_literal: true

require 'httparty'
require 'json'

class UserApi < WcaApi
  def self.permissions_path(user_id)
    "#{EnvConfig.WCA_HOST}/api/internal/v1/users/#{user_id}/permissions"
  end

  def self.competitor_info_path
    "#{EnvConfig.WCA_HOST}/api/internal/v1/users/competitor-info"
  end

  def self.competitor_qualifications_path(user_id, date = nil)
    if date.present?
      "#{EnvConfig.WCA_HOST}/api/v0/results/#{user_id}/qualification_data?date=#{date}"
    else
      "#{EnvConfig.WCA_HOST}/api/v0/results/#{user_id}/qualification_data"
    end
  end

  def self.get_permissions(user_id)
    HTTParty.get(permissions_path(user_id), headers: { WCA_API_HEADER => self.wca_token })
  end

  def self.get_user_info_pii(user_ids)
    HTTParty.post(UserApi.competitor_info_path, headers: { WCA_API_HEADER => self.wca_token }, body: { ids: user_ids.to_a })
  end

  def self.qualifications(user_id, date = nil)
    HTTParty.get(UserApi.competitor_qualifications_path(user_id, date), headers: { WCA_API_HEADER => self.wca_token })
  end

  def self.can_compete?(user_id, competition_start_date)
    # All User Related cache Keys should start with the UserID, so we could invalidate them on user update
    # TODO: Move this to it's own cache helper class so this is guaranteed?
    permissions = Rails.cache.fetch("#{user_id}-permissions", expires_in: 5.minutes) do
      self.get_permissions(user_id)
    end

    competition_permissions = permissions['can_attend_competitions']
    competition_start = DateTime.parse(competition_start_date)
    ban_end = DateTime.parse(permissions['can_attend_competitions']['until'] || '3099-09-09')

    competition_permissions['scope'] == '*' || ban_end < competition_start
  end

  def self.can_administer?(user_id, competition_id)
    permissions = Rails.cache.fetch("#{user_id}-permissions", expires_in: 5.minutes) do
      self.get_permissions(user_id)
    end
    permissions['can_administer_competitions']['scope'] == '*' || permissions['can_administer_competitions']['scope'].include?(competition_id)
  end
end
