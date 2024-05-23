# frozen_string_literal: true

require 'httparty'
require 'json'
require_relative 'wca_api'

def permissions_path(user_id)
  "#{EnvConfig.WCA_HOST}/api/internal/v1/users/#{user_id}/permissions"
end

def competitor_info_path
  "#{EnvConfig.WCA_HOST}/api/internal/v1/users/competitor-info"
end

def users_info_path(ids)
  ids_query = ids.map { |id| "ids[]=#{id}" }.join('&')
  "#{EnvConfig.WCA_HOST}/api/v0/users?#{ids_query}"
end

class UserApi < WcaApi
  def self.get_permissions(user_id)
    HTTParty.get(permissions_path(user_id), headers: { WCA_API_HEADER => self.wca_token })
  end

  def self.get_user_info_pii(user_ids)
    HTTParty.post(competitor_info_path, headers: { WCA_API_HEADER => self.wca_token }, body: { ids: user_ids.to_a })
  end

  def self.can_compete?(user_id, competition_start_date)
    # All User Related cache Keys should start with the UserID, so we could invalidate them on user update
    # TODO: Move this to it's own cache helper class so this is guaranteed?
    permissions = Rails.cache.fetch("#{user_id}-permissions", expires_in: 5.minutes) do
      self.get_permissions(user_id)
    end

    competition_permissions = permissions['can_attend_competitions']

    # User can compete if they have global attend permissions
    return true if competition_permissions['scope'] == '*'

    # If the above check fails, then the user is banned. Return false if they are permabanned
    return false unless competition_permissions['until'].present?

    # If the user's ban has an end date, check if the ban ends before the competition starts
    ban_end = DateTime.parse(permissions['can_attend_competitions']['until'])
    competition_start = DateTime.parse(competition_start_date)
    ban_end < competition_start
  end

  def self.can_administer?(user_id, competition_id)
    permissions = Rails.cache.fetch("#{user_id}-permissions", expires_in: 5.minutes) do
      self.get_permissions(user_id)
    end
    permissions['can_administer_competitions']['scope'] == '*' || permissions['can_administer_competitions']['scope'].include?(competition_id)
  end
end
