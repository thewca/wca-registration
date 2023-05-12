require 'json'
class QueuePollerJob < ApplicationJob
  queue_as :default

  # Wait for 1 second so we can start work on 10 messages at at time
  # These numbers can be tweaked after load testing
  WAIT_TIME = 1
  MAX_MESSAGES = 10

  def perform
    sqs = Aws::SQS::Client.new(endpoint: ENV['LOCALSTACK_ENDPOINT'])
    queue = sqs.get_queue_url(queue_name: "registrations.fifo").queue_url
    poller = Aws::SQS::QueuePoller.new(queue)
    poller.poll(wait_time_seconds: WAIT_TIME, max_number_of_messages: MAX_MESSAGES) do |messages|
      messages.each do |msg|
        # Messages are deleted from the queue when the block returns normally!
        puts "Received message with ID: #{msg.message_id}"
        puts "Message body: #{msg.body}"
        body = JSON.parse msg.body
        begin
          RegistrationProcessor.process_message(body)
        rescue
          # unexpected error occurred while processing messages,
          # log it, and skip delete so it can be re-processed later
          throw :skip_delete
        end
      end
    end
  end
end
