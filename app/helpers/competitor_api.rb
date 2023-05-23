# frozen_string_literal: true
require 'uri'
require 'net/http'
require 'json'

class CompetitorApi
  def self.check_competitor(competitor_id)
    uri = URI("https://www.worldcubeassociation.org/api/v0/users/#{competitor_id}")
    res = Net::HTTP.get_response(uri)
    if res.is_a?(Net::HTTPSuccess)
      body = JSON.parse res.body
      body["user"].present?
    else
      # The Competitor Service is unreachable TODO We should track this as a metric
      puts 'network request failed'
      false
    end
  end
end
