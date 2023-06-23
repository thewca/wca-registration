# frozen_string_literal: true

require 'dynamoid'

Dynamoid.configure do |config|
  config.region = ENV.fetch("AWS_REGION", 'us-west-2')
  config.namespace = nil
  if Rails.env.production?
    config.credentials = Aws::ECSCredentials.new(retries: 3)
  else
    config.endpoint = ENV.fetch('LOCALSTACK_ENDPOINT', nil)
  end
end
