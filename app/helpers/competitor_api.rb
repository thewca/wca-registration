# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'json'

class CompetitorApi
  def self.check_competitor(competitor_id)
    uri = URI("https://www.worldcubeassociation.org/api/v0/users/#{competitor_id}")
    begin
      res = Net::HTTP.get_response(uri)
      if res.is_a?(Net::HTTPSuccess)
        body = JSON.parse res.body
        body['user'].present?
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
end
