# frozen_string_literal: true

require 'superconfig'

# Don't run this on the handler
unless defined?(Rails)
  EnvConfig = SuperConfig.new do
    # We don't have RAILS_ENV in ruby
    if ENV.fetch('CODE_ENVIRONMENT', 'development') == 'development'
      mandatory :LOCALSTACK_ENDPOINT, :string
      # Have to be the same as in localstack to simulate authentication
      mandatory :AWS_ACCESS_KEY_ID, :string
      mandatory :AWS_SECRET_ACCESS_KEY, :string
      optional :WCA_HOST, :string, ''
      optional :CODE_ENVIRONMENT, 'development'
    else
      mandatory :QUEUE_URL, :string
      mandatory :WCA_HOST, :string
      mandatory :CODE_ENVIRONMENT, :string
    end
    # We even need the AWS_REGION in dev because we fake authenticate with localstack
    mandatory :AWS_REGION, :string
    mandatory :PROMETHEUS_EXPORTER, :string
    mandatory :DYNAMO_REGISTRATIONS_TABLE, :string
    mandatory :REGISTRATION_HISTORY_DYNAMO_TABLE, :string
  end
end
