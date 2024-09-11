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

  def self.url(competition_id)
    "#{EnvConfig.WCA_HOST}/api/v0/competitions/#{competition_id}"
  end

  def self.find!(competition_id)
    competition_json = fetch_competition(competition_id)
    CompetitionInfo.new(competition_json)
  end

  def self.fetch_qualifications(competition_id)
    Rails.cache.fetch("#{competition_id}/qualifications", expires_in: 5.minutes) do
      response = HTTParty.get("#{url(competition_id)}/qualifications")
      case response.code
      when 200
        @status = 200
        response.parsed_response
      when 404
        Metrics.increment('registration_competition_api_error_counter')
        raise RegistrationError.new(404, ErrorCodes::COMPETITION_NOT_FOUND)
      else
        Metrics.increment('registration_competition_api_error_counter')
        raise RegistrationError.new(response.code.to_i, ErrorCodes::COMPETITION_API_5XX)
      end
    end
  end

  private_class_method def self.fetch_competition(competition_id)
    Rails.cache.fetch(competition_id, expires_in: 5.minutes) do
      response = HTTParty.get(CompetitionApi.url(competition_id))
      case response.code
      when 200
        response.parsed_response
      when 404
        Metrics.increment('registration_competition_api_error_counter')
        raise RegistrationError.new(404, ErrorCodes::COMPETITION_NOT_FOUND)
      else
        Metrics.increment('registration_competition_api_error_counter')
        raise RegistrationError.new(response.code.to_i, ErrorCodes::COMPETITION_API_5XX)
      end
    end
  end
end
