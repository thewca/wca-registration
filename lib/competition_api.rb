# frozen_string_literal: true

require 'httparty'
require 'uri'
require 'json'

class CompetitionApi < WcaApi
  def self.find(competition_id)
    competition_json = fetch_competition(competition_id)
    CompetitionInfo.new(competition_json)
  end

  def self.url(competition_id)
    "#{EnvConfig.WCA_HOST}/api/v0/competitions/#{competition_id}"
  end

  def self.fetch_qualifications(competition_id)
    self.get_request("#{url(competition_id)}/qualifications")
  rescue RegistrationError => e
    if (e.data[:http_code] = 404)
      raise RegistrationError.new(404, ErrorCodes::COMPETITION_NOT_FOUND)
    else
      raise e
    end
  end

  private_class_method def self.fetch_competition(competition_id)
    self.get_request(url(competition_id))
  rescue RegistrationError => e
    if (e.data[:http_code] = 404)
      raise RegistrationError.new(404, ErrorCodes::COMPETITION_NOT_FOUND)
    else
      raise e
    end
  end
end
