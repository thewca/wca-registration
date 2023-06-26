# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'json'
require_relative 'mocks'

class UserApi
  def self.fetch_user(user_id)
    uri = URI("https://www.worldcubeassociation.org/api/v0/users/#{user_id}")
    begin
      res = Net::HTTP.get_response(uri)
      if res.is_a?(Net::HTTPSuccess)
        body = JSON.parse res.body
        return body["user"]
      else
        # The Competitor Service is unreachable
        Metrics.registration_competitor_api_error_counter.increment
        puts 'network request failed'
        false
      end
    rescue StandardError => _e
      puts 'The service does not have internet'
      Metrics.registration_competitor_api_error_counter.increment
      false
    end
  end

  # TODO: The real permission route will live in the user service
  def self.get_permissions(user_id)
    permissions_mock(user_id)
  end

  def self.can_compete?(user_id)
    # All User Related cache Keys should start with the UserID, so we could invalidate them on user update
    # TODO: Move this to it's own cache helper class so this is guaranteed?
    permissions = Rails.cache.fetch("#{user_id}-permissions", expires_in: 5.minutes) do
      self.get_permissions(user_id)
    end
    permissions.can_attend_competitions == "*"
  end

  def self.cannot_compete_reasons(user_id)
    permissions = Rails.cache.fetch("#{user_id}-permissions", expires_in: 5.minutes) do
      self.get_permissions(user_id)
    end
    permissions.reasons
  end

  def self.can_administer?(user_id, competition_id)
    permissions = Rails.cache.fetch("#{user_id}-permissions", expires_in: 5.minutes) do
      self.get_permissions(user_id)
    end
    permissions.can_organize_competitions == "*" || permissions.can_organize_competitions.include?(competition_id)
  end
end
