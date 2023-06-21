# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'json'

class CompetitionApi
  def self.fetch_competition(competition_id)
    uri = URI("https://www.worldcubeassociation.org/api/v0/competitions/#{competition_id}")
    res = Net::HTTP.get_response(uri)
    if res.is_a?(Net::HTTPSuccess)
      body = JSON.parse res.body
      return body
    else
      Metrics.registration_competition_api_error_counter.increment
      puts 'network request failed'
      false
    end
  end

  def self.is_open?(competition_id)
    competition_info = Rails.cache.fetch(competition_id, expires_in: 5.minutes) do
      self.fetch_competition(competition_id)
    end
    competition_info["registration_open"] < Time.now && competition_info["registration_close"] > Time.now
  end

  def self.events_held?(event_ids, competition_id)
    competition_info = Rails.cache.fetch(competition_id, expires_in: 5.minutes) do
      self.fetch_competition(competition_id)
    end
    competition_info["event_ids"].to_set.superset?(event_ids.to_set)
  end
end
