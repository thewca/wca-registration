# frozen_string_literal: true

# config/initializers/aws.rb

if Rails.env.production?
  $dynamodb = Aws::DynamoDB::Client.new
  $sqs = Aws::SQS::Client.new
  $queue = ENV.fetch('QUEUE_URL', nil)
else
  # We are using localstack to emulate AWS in dev
  $dynamodb = Aws::DynamoDB::Client.new(endpoint: ENV.fetch('LOCALSTACK_ENDPOINT', nil))
  $sqs = Aws::SQS::Client.new(endpoint: ENV.fetch('LOCALSTACK_ENDPOINT', nil))
end
