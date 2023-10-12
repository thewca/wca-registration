# frozen_string_literal: true

require 'httparty'
require 'json'
require_relative 'mocks'
require_relative 'wca_api'

class UserApi < WcaApi
  def self.get_permissions(user_id)
    if Rails.env.production?
      HTTParty.get(permissions_path(user_id), headers: { WCA_API_HEADER => self.get_wca_token })
    else
      Mocks.permissions_mock(user_id)
    end
  end

  def self.can_compete?(user_id)
    # All User Related cache Keys should start with the UserID, so we could invalidate them on user update
    # TODO: Move this to it's own cache helper class so this is guaranteed?
    permissions = Rails.cache.fetch("#{user_id}-permissions", expires_in: 5.minutes) do
      self.get_permissions(user_id)
    end
    [permissions["can_attend_competitions"]["scope"] == "*", permissions["can_attend_competitions"]["reasons"]]
  end

  def self.can_administer?(user_id, competition_id)
    permissions = Rails.cache.fetch("#{user_id}-permissions", expires_in: 5.minutes) do
      self.get_permissions(user_id)
    end
    permissions["can_administer_competitions"]["scope"] == "*" || permissions["can_administer_competitions"]["scope"].include?(competition_id)
  end

  private
    def permissions_path(user_id)
      "#{WCA_HOST}/api/internal/v1/users/#{user_id}/permissions"
    end
end
