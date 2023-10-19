# frozen_string_literal: true

require 'prometheus_exporter/client'
require 'prometheus_exporter/instrumentation'
require 'prometheus_exporter/metric'

require_relative '../../app/helpers/metrics'

PrometheusExporter::Client.default = PrometheusExporter::Client.new(host: ENV.fetch('PROMETHEUS_EXPORTER'), port: 9091)

if Rails.env.production? && !EnvConfig.REGISTRATION_LIVE_SITE?
  PrometheusExporter::Instrumentation::Process.start(type: 'wca-registration-handler-staging', labels: { process: '1' })
  suffix = '-staging'
else
  PrometheusExporter::Instrumentation::Process.start(type: 'wca-registration-handler', labels: { process: '1' })
  suffix = ''
end

unless Rails.env.test?
  require 'prometheus_exporter/middleware'

  # This reports stats per request like HTTP status and timings
  Rails.application.middleware.unshift PrometheusExporter::Middleware
end

# Create our Metric Counters
Metrics.registration_dynamodb_errors_counter = PrometheusExporter::Client.default.register('counter', "registration_dynamodb_errors_counter#{suffix}", 'The number of times interacting with dynamodb fails')
Metrics.registration_competition_api_error_counter = PrometheusExporter::Client.default.register('counter', "registration_competition_api_error_counter#{suffix}", 'The number of times interacting with the competition API failed')
Metrics.registration_competitor_api_error_counter = PrometheusExporter::Client.default.register('counter', "registration_competitor_api_error_counter#{suffix}", 'The number of times interacting with the user API failed')
Metrics.registration_validation_errors_counter = PrometheusExporter::Client.default.register('counter', "registration_validation_errors_counter#{suffix}", 'The number of times validation fails when an attendee tries to register')
Metrics.jwt_verification_error_counter = PrometheusExporter::Client.default.register('counter', "jwt_verification_error_counter#{suffix}", 'The number of times JWT verification failed')
Metrics.registration_impersonation_attempt_counter = PrometheusExporter::Client.default.register('counter', "registration_impersonation_attempt_counter#{suffix}", 'The number of times a Person tries to register as someone else')
