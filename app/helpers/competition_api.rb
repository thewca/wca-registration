# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'json'

require_relative 'error_codes'
require_relative 'wca_api'

BASE_COMP_URL = "https://test-registration.worldcubeassociation.org/api/v10/competitions/"

class CompetitionApi < WcaApi
  attr_accessor :competition_info, :error, :status

  def initialize(competition_id)
    fetch_competition(competition_id)
  end

  def fetch_competition(competition_id)
    Rails.cache.fetch(competition_id, expires_in: 5.minutes) do
      uri = URI("#{BASE_COMP_URL}#{competition_id}")
      res = Net::HTTP.get_response(uri)
      case res
      when Net::HTTPSuccess
        @status = 200
        @competition_info = CompetitionInfo.new(JSON.parse(res.body))
      when Net::HTTPNotFound
        Metrics.registration_competition_api_error_counter.increment
        @error = ErrorCodes::COMPETITION_NOT_FOUND
        @status = 404
      else
        Metrics.registration_competition_api_error_counter.increment
        @error = ErrorCodes::COMPETITION_API_5XX
        @status = res.code.to_i
      end
    end
  end

  def competition_exists?
    @error.nil?
  end
end

class CompetitionInfo
  def initialize(competition_json)
    @competition_json = competition_json
  end

  def event_change_deadline
    @competition_json['event_change_deadline_date']
  end

  def competitor_limit
    @competition_json['competitor_limit']
  end

  def guest_entry_status
    @competition_json['guest_entry_status']
  end

  def guest_limit
    @competition_json['guests_per_registration_limit']
  end

  def competition_open?
    puts @competition_json
    @competition_json["registration_opened?"]
  end

  def using_wca_payment?
    @competition_json["using_stripe_payments?"]
  end

  def force_comment?
    @competition_json['force_comment_in_registration']
  end

  def events_held?(event_ids)
    @competition_json["event_ids"].to_set.superset?(event_ids.to_set)
  end

  def payment_info
    [@competition_json["base_entry_fee_lowest_denomination"], @competition_json["currency_code"]]
  end

  def json
    @competition_json
  end

  def name
    @competition_json["name"]
  end
end
