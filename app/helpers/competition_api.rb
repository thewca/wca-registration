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
      { error: ErrorCodes::COMPETITION_NOT_FOUND, status: 404 }
    else
      Metrics.registration_competition_api_error_counter.increment
      { error: ErrorCodes::COMPETITION_API_5XX, status: res.code }
    end
  end

  def self.competition_exists?(competition_id)
    Rails.cache.fetch(competition_id, expires_in: 5.minutes) do
      self.fetch_competition(competition_id)
    end
  end

  def self.uses_wca_payment?(competition_id)
    competition_info = Rails.cache.fetch(competition_id, expires_in: 5.minutes) do
      self.fetch_competition(competition_id)
    end
    competition_info[:competition_info]["using_stripe_payments?"]
  end

  def self.events_held?(event_ids, competition_id)
    competition_info = Rails.cache.fetch(competition_id, expires_in: 5.minutes) do
      self.fetch_competition(competition_id)
    end
    competition_info[:competition_info]["event_ids"].to_set.superset?(event_ids.to_set)
  end

  def payment_info(competition_id)
    competition_info = Rails.cache.fetch(competition_id, expires_in: 5.minutes) do
      self.fetch_competition(competition_id)
    end
    [competition_info[:competition_info]["base_entry_fee_lowest_denomination"], competition_info[:competition_info]["currency_code"]]
  end
end
