# frozen_string_literal: true

require 'httparty'
require 'uri'
require 'json'

require_relative 'error_codes'
require_relative 'wca_api'

def comp_api_url(competition_id)
  "https://#{EnvConfig.WCA_HOST}/api/v0/competitions/#{competition_id}"
end

class CompetitionApi < WcaApi
  def self.find(competition_id)
    competition_json = if Rails.env.development?
                         Mocks.mock_competition(competition_id)
                       else
                         fetch_competition(competition_id)
                       end
    CompetitionInfo.new(competition_json)
  rescue RegistrationError
    nil
  end

  def self.find!(competition_id)
    competition_json = if Rails.env.development?
                         Mocks.mock_competition(competition_id)
                       else
                         fetch_competition(competition_id)
                       end
    CompetitionInfo.new(competition_json)
  end

  # This is how you make a private class method
  class << self
    def fetch_competition(competition_id)
      Rails.cache.fetch(competition_id, expires_in: 5.minutes) do
        response = HTTParty.get(comp_api_url(competition_id))
        case response.code
        when 200
          @status = 200
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

class CompetitionInfo
  attr_accessor :competition_id

  def initialize(competition_json)
    @competition_json = competition_json
    @competition_id = competition_json['id']
  end

  def within_event_change_deadline?
    Time.now < @competition_json['event_change_deadline_date']
  end

  def competitor_limit
    @competition_json['competitor_limit']
  end

  def guest_limit_exceeded?(guest_count)
    return false unless @competition_json['guests_per_registration_limit'].present?
    @competition_json['guest_entry_status'] == 'restricted' && @competition_json['guests_per_registration_limit'] < guest_count
  end

  def event_limit
    if @competition_json['events_per_registration_limit'].is_a? Integer
      @competition_json['events_per_registration_limit']
    else
      nil
    end
  end

  def guest_limit
    @competition_json['guests_per_registration_limit']
  end

  def registration_open?
    @competition_json['registration_opened?']
  end

  def using_wca_payment?
    @competition_json['using_stripe_payments?']
  end

  def force_comment?
    @competition_json['force_comment_in_registration']
  end

  def events_held?(event_ids)
    event_ids != [] && @competition_json['event_ids'].to_set.superset?(event_ids.to_set)
  end

  def payment_info
    [@competition_json['base_entry_fee_lowest_denomination'], @competition_json['currency_code']]
  end

  def is_organizer_or_delegate?(user_id)
    (@competition_json['delegates'] + @competition_json['organizers']).any? { |p| p['id'] == user_id }
  end

  def name
    @competition_json['name']
  end

  def registration_edits_allowed?
    @competition_json['allow_registration_edits'] && within_event_change_deadline?
  end

  def user_can_cancel?
    @competition_json['allow_registration_self_delete_after_acceptance']
  end

  def other_series_ids
    @competition_json['competition_series_ids']&.reject { |id| id == competition_id }
  end
end
