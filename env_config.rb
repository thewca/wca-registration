# frozen_string_literal: true

require 'superconfig'

EnvConfig = SuperConfig.new do
  if Rails.env.production?
    mandatory :HOST, :string
    mandatory :VAULT_ADDR, :string
    mandatory :TASK_ROLE, :string
    mandatory :REGISTRATION_LIVE_SITE, :bool
    mandatory :WCA_HOST, :string
    mandatory :REDIS_URL, :string
    mandatory :VAULT_APPLICATION, :string
    mandatory :BUILD_TAG, :string
  else
    mandatory :LOCALSTACK_ENDPOINT, :string
    # Have to be the same as in localstack to simulate authentication
    mandatory :AWS_ACCESS_KEY_ID, :string
    mandatory :AWS_SECRET_ACCESS_KEY, :string
    optional :WCA_HOST, :string, ''
    optional :REDIS_URL, :string, ''
    optional :BUILD_TAG, :string, 'local'
  end
  # We even need the AWS_REGION in dev because we fake authenticate with localstack
  mandatory :AWS_REGION, :string
  mandatory :DYNAMO_REGISTRATIONS_TABLE, :string
  mandatory :REGISTRATION_HISTORY_DYNAMO_TABLE, :string
  mandatory :WAITING_LIST_DYNAMO_TABLE, :string
  mandatory :QUEUE_NAME, :string
end
