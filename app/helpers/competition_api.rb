# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'json'

require_relative 'error_codes'
require_relative 'wca_api'
class CompetitionApi < WcaApi
  def self.fetch_competition(competition_id)
    uri = URI("https://test-registration.worldcubeassociation.org/api/v10/competitions/#{competition_id}")
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

  def self.get_competition_info(competition_id)
    puts "retrieving comp info"
    competition_info = Rails.cache.fetch(competition_id, expires_in: 5.minutes) do
      self.fetch_competition(competition_id)
    end
    puts "raw comp info: #{competition_info}"
    puts "error: #{competition_info[:error]}"
    puts "befre if"

    if competition_info[:error] == false
      puts "no error"
      competition_info[:competition_exists?] = true
      competition_info[:competition_open?] = competition_info[:competition_info]["registration_opened?"]
    else
      puts "there's an error"
      if competition_info[:error] == ErrorCodes::COMPETITION_NOT_FOUND
        puts "competition not found"
        competition_info[:competition_exists?] = false
      else
        puts "some other error"
        # If there's any other kind of error we don't know whether the competition exists or not
        competition_info[:competition_exists?] = nil
      end
    end
    puts "final comp info: #{competition_info}"
    competition_info
  end

  def self.competition_open?(competition_id)
    puts "checking if open"
    competition_info = Rails.cache.fetch(competition_id, expires_in: 5.minutes) do
      self.fetch_competition(competition_id)
    end
    puts "fetched competition: #{competition_info}"
    competition_info[:competition_info]["registration_opened?"]
  end

  def self.competition_exists?(competition_id)
    puts "checking if exists"
    competition_info = Rails.cache.fetch(competition_id, expires_in: 5.minutes) do
      self.fetch_competition(competition_id)
    end

    if competition_info[:error] == false
      true
    else
      competition_info
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

  def self.payment_info(competition_id)
    competition_info = Rails.cache.fetch(competition_id, expires_in: 5.minutes) do
      self.fetch_competition(competition_id)
    end
    [competition_info[:competition_info]["base_entry_fee_lowest_denomination"], competition_info[:competition_info]["currency_code"]]
  end
end
