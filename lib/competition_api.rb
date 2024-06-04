# frozen_string_literal: true

require 'httparty'
require 'uri'
require 'json'

class CompetitionApi < WcaApi
  def self.find(competition_id)
    competition_json = fetch_competition(competition_id)
    CompetitionInfo.new(competition_json)
  rescue RegistrationError
    nil
  end

  def self.comp_api_url(competition_id)
    "#{EnvConfig.WCA_HOST}/api/v0/competitions/#{competition_id}"
  end


  def self.find!(competition_id)
    competition_json = fetch_competition(competition_id)
    CompetitionInfo.new(competition_json)
  end

  # This is how you make a private class method
  class << self
    def fetch_competition(competition_id)
      Rails.cache.fetch(competition_id, expires_in: 5.minutes) do
        response = HTTParty.get(CompetitionApi.comp_api_url(competition_id))
        case response.code
        when 200
          JSON.parse response.body
        when 404
          Metrics.registration_competition_api_error_counter.increment
          raise RegistrationError.new(404, ErrorCodes::COMPETITION_NOT_FOUND)
        else
          Metrics.registration_competition_api_error_counter.increment
          raise RegistrationError.new(response.code.to_i, ErrorCodes::COMPETITION_API_5XX)
        end
      end
    end
  end
end
