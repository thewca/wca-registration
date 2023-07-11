# frozen_string_literal: true

require 'json'
require 'aws-sdk-sqs'
require 'prometheus_exporter/client'
require 'prometheus_exporter/instrumentation'
require 'prometheus_exporter/metric'
require_relative 'registration_processor'

class QueuePoller
  # Wait for 1 second so we can start work on 10 messages at at time
  # These numbers can be tweaked after load testing
  WAIT_TIME = 1
  MAX_MESSAGES = 10

  def self.perform
    PrometheusExporter::Client.default = PrometheusExporter::Client.new(host: ENV.fetch("PROMETHEUS_EXPORTER"), port: 9091)
    # Instrumentation of the worker process is currently disabled per https://github.com/discourse/prometheus_exporter/issues/282
    if ENV.fetch("CODE_ENVIRONMENT", "dev") == "staging"
      # PrometheusExporter::Instrumentation::Process.start(type: "wca-registration-worker-staging", labels: { process: "1" })
      @suffix = "-staging"
    else
      # PrometheusExporter::Instrumentation::Process.start(type: "wca-registration-worker", labels: { process: "1" })
      @suffix = ""
    end
    registrations_counter = PrometheusExporter::Client.default.register("counter", "registrations_counter-#{@suffix}", "The number of Registrations processed")
    error_counter = PrometheusExporter::Client.default.register("counter", "worker_error_counter-#{@suffix}", "The number of Errors in the worker")

    @sqs ||= if ENV['LOCALSTACK_ENDPOINT']
               Aws::SQS::Client.new(endpoint: ENV['LOCALSTACK_ENDPOINT'])
             else
               Aws::SQS::Client.new
             end
    queue_url = ENV["QUEUE_URL"] || @sqs.get_queue_url(queue_name: 'registrations.fifo').queue_url
    processor = RegistrationProcessor.new
    poller = Aws::SQS::QueuePoller.new(queue_url)
    poller.poll(wait_time_seconds: WAIT_TIME, max_number_of_messages: MAX_MESSAGES) do |messages|
      messages.each do |msg|
        # messages are deleted from the queue when the block returns normally!
        puts "Received message with ID: #{msg.message_id}"
        puts "Message body: #{msg.body}"
        body = JSON.parse msg.body
        begin
          processor.process_message(body)
          registrations_counter.increment
        rescue StandardError => e
          # unexpected error occurred while processing messages,
          # log it, and skip delete so it can be re-processed later
          puts "Error #{e} when processing message with ID #{msg}"
          error_counter.increment
          throw :skip_delete
        end
      end
    end
  end
end
