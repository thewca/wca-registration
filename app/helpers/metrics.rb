# frozen_string_literal: true

module Metrics
  class << self
    attr_accessor :registration_validation_errors_counter, :registration_dynamodb_errors_counter, :registrations_counter, :registration_competition_api_error_counter, :registration_competitor_api_error_counter
  end
end
