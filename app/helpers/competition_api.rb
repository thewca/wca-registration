# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'json'

class CompetitionApi
  def self.check_competition(competition_id)
    uri = URI("https://www.worldcubeassociation.org/api/v0/competitions/#{competition_id}")
    res = Net::HTTP.get_response(uri)
    if res.is_a?(Net::HTTPSuccess)
      body = JSON.parse res.body
      body['registration_open'].present?
    else
      Metrics.registration_competition_api_error_counter.increment
      puts 'network request failed'
      false
    end
  end
end
