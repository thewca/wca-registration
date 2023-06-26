# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'json'

require_relative 'error_codes'
class CompetitionApi
  def self.fetch_competition(competition_id)
    uri = URI("https://www.worldcubeassociation.org/api/v0/competitions/#{competition_id}")
    res = Net::HTTP.get_response(uri)
    case res
    when Net::HTTPSuccess
      body = JSON.parse res.body
      { error: false, competition_info: body }
    when Net::HTTPNotFound
      Metrics.registration_competition_api_error_counter.increment
      { error: COMPETITION_API_NOT_FOUND, status: 404 }
    else
      Metrics.registration_competition_api_error_counter.increment
      { error: COMPETITION_API_5XX, status: res.code }
    end
  end

  def self.competition_exists?(competition_id)
    Rails.cache.fetch(competition_id, expires_in: 5.minutes) do
      self.fetch_competition(competition_id)
    end
  end
end
