# frozen_string_literal: true

require 'prometheus_exporter/client'
require 'prometheus_exporter/instrumentation'
require 'prometheus_exporter/metric'

require_relative '../../app/helpers/metrics'

PrometheusExporter::Client.default = PrometheusExporter::Client.new(host: ENV.fetch("PROMETHEUS_EXPORTER"), port:9394)
PrometheusExporter::Instrumentation::Process.start(type: "wca-registration-handler", labels: {process: "1"})

unless Rails.env.test?
  require 'prometheus_exporter/middleware'

  # This reports stats per request like HTTP status and timings
  Rails.application.middleware.unshift PrometheusExporter::Middleware
end

# Create our Metric Counters
Metrics.registration_dynamodb_errors_counter = PrometheusExporter::Client.default.register("counter", "registration_dynamodb_errors_counter", "The number of times interacting with dynamodb fails")
Metrics.registration_competition_api_error_counter = PrometheusExporter::Client.default.register("counter", "registration_competition_api_error_counter", "The number of times interacting with the competition API failed")
Metrics.registration_competitor_api_error_counter = PrometheusExporter::Client.default.register("counter", "registration_competitor_api_error_counter", "The number of times interacting with the competitor API failed")
Metrics.registration_validation_errors_counter = PrometheusExporter::Client.default.register("counter",  "registration_validation_errors_counter", "The number of times validation fails when an attendee tries to register")