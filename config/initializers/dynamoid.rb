# frozen_string_literal: true

require 'dynamoid'

Dynamoid.configure do |config|
  config.region = EnvConfig.AWS_REGION
  config.namespace = nil
  if Rails.env.production?
    config.credentials = Aws::ECSCredentials.new(retries: 3)
  else
    config.endpoint = EnvConfig.LOCALSTACK_ENDPOINT
  end
end
