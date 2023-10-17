# This file starts with _ because it has to be the first one run
# frozen_string_literal: true

require 'vault'

Vault.configure do |vault|
  role_credentials = Aws::ECSCredentials.new
  Vault.auth.aws_iam(EnvConfig.TASK_ROLE, role_credentials, nil, "https://sts.#{EnvConfig.AWS_REGION}.amazonaws.com")

  vault.ssl_verify = false

  # Timeout the connection after a certain amount of time (seconds), also read
  # as ENV["VAULT_TIMEOUT"]
  vault.timeout = 30

  # It is also possible to have finer-grained controls over the timeouts, these
  # may also be read as environment variables
  vault.ssl_timeout  = 5
  vault.open_timeout = 5
  vault.read_timeout = 30
end
