# frozen_string_literal: true

require 'superconfig'

EnvConfig = SuperConfig.new do
  if Rails.env.production?
    mandatory :HOST, :string
    mandatory :VAULT_ADDR, :string
    mandatory :TASK_ROLE, :string
    mandatory :REGISTRATION_LIVE_SITE, :bool
    mandatory :QUEUE_URL, :string
    mandatory :WCA_HOST, :string
  else
    mandatory :LOCALSTACK_ENDPOINT, :string
    # Have to be the same as in localstack to simulate authentication
    mandatory :AWS_ACCESS_KEY_ID, :string
    mandatory :AWS_SECRET_ACCESS_KEY, :string
    optional :WCA_HOST, :string, ''
  end
  # We even need the AWS_REGION in dev because we fake authenticate with localstack
  mandatory :AWS_REGION, :string
  mandatory :PROMETHEUS_EXPORTER, :string
  mandatory :REDIS_URL, :string
  mandatory :DYNAMO_REGISTRATIONS_TABLE, :string
end
