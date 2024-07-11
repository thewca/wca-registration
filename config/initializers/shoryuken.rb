# frozen_string_literal: true

Shoryuken.configure_client do |config|
  if Rails.env.local?
    config.sqs_client = Aws::SQS::Client.new(
      region: EnvConfig.AWS_REGION,
      access_key_id: EnvConfig.AWS_ACCESS_KEY_ID,
      secret_access_key: EnvConfig.AWS_SECRET_ACCESS_KEY,
      endpoint: EnvConfig.LOCALSTACK_ENDPOINT,
      verify_checksums: false,
    )
  end
end

Shoryuken.configure_server do |config|
  if Rails.env.local?
    config.sqs_client = Aws::SQS::Client.new(
      region: EnvConfig.AWS_REGION,
      access_key_id: EnvConfig.AWS_ACCESS_KEY_ID,
      secret_access_key: EnvConfig.AWS_SECRET_ACCESS_KEY,
      endpoint: EnvConfig.LOCALSTACK_ENDPOINT,
      verify_checksums: false,
    )
  end
end
