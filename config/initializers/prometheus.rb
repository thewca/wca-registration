# frozen_string_literal: true

require 'prometheus/client'

# returns a default registry
prometheus = Prometheus::Client.registry

# Create our Metric Counters
Metrics.registration_validation_errors_counter = prometheus.counter(:registration_validation_errors_counter, docstring: 'The number of times validation fails when an attendee tries to register')
Metrics.registration_dynamodb_errors_counter = prometheus.counter(:registration_dynamodb_errors_counter, docstring: 'The number of times interacting with dynamodb fails')
Metrics.registrations_counter = prometheus.counter(:registrations_counter, docstring: 'The number of Registrations processed')
