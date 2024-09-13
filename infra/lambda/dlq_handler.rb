# frozen_string_literal: true

require 'json'
require 'dynamoid'
require 'aws-sdk-dynamodb'
require 'aws-sdk-sns'
require 'superconfig'
require 'zeitwerk'

Dynamoid.configure do |config|
  config.region = ENV.fetch('AWS_REGION', 'us-west-2')
  config.namespace = nil
end

EnvConfig = SuperConfig.new do
  mandatory :DYNAMO_REGISTRATIONS_TABLE, :string
  mandatory :REGISTRATION_HISTORY_DYNAMO_TABLE, :string
  mandatory :SNS_TOPIC_ARN, :string
end

loader = Zeitwerk::Loader.new
loader.push_dir('./registration_lib')
loader.setup

def lambda_handler(event:, context:)
  # Parse the incoming event data
  step_data = JSON.parse(event['Records'][0]['body'])

  attendee_id = step_data['attendee_id']
  competition_id = step_data['competition_id']
  user_id = step_data['user_id']

  # Find the registration in DynamoDB
  registration = Registration.find(attendee_id)

  # Initialize SNS client
  sns = Aws::SNS::Client.new(region: ENV['AWS_REGION'])

  # Handle the result based on registration status
  if registration
    message = "Competitor with user ID #{user_id} for competition #{competition_id} was registered, meaning the error occurred after registration. This should be fixed, but can be ignored temporally."
  else
    message = "Competitor with user ID #{user_id} for competition #{competition_id} was NOT registered. This should be fixed as soon as possible."
  end

  # Publish message to SNS topic
  sns.publish({
                topic_arn: ENV['SNS_TOPIC_ARN'],
                message: message
              })
end
