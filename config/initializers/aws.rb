# frozen_string_literal: true

# config/initializers/aws.rb

if Rails.env.production?
  $dynamodb = Aws::DynamoDB::Client.new
  $sqs = Aws::SQS::Client.new
else
  # We are using localstack to emulate AWS in dev
  $dynamodb = Aws::DynamoDB::Client.new(endpoint: EnvConfig.LOCALSTACK_ENDPOINT)
  $sqs = Aws::SQS::Client.new(endpoint: EnvConfig.LOCALSTACK_ENDPOINT)
end
