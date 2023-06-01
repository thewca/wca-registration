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
Metrics.registration_validation_errors_counter = PrometheusExporter::Metric::Counter.new("registration_validation_errors_counter", 'The number of times validation fails when an attendee tries to register')
Metrics.registration_dynamodb_errors_counter = PrometheusExporter::Metric::Counter.new("registration_dynamodb_errors_counter", "'The number of times interacting with dynamodb fails'")
