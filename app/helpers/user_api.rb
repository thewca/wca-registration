# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'json'

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
  def profile_complete?(user_id)
    # This needs to come from the user service*, but currently no route exists that gives this info
    true
  end

  def is_banned?(user_id)
    # This needs to come from the user service*, but currently no route exists that gives this info
    false
  end
end
