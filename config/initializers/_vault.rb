# This file starts with _ because it has to be the first one run
# frozen_string_literal: true

require 'vault/rails'

Vault.configure do |vault|
  # Use Vault in transit mode for encrypting and decrypting data. If
  # disabled, vault-rails will encrypt data in-memory using a similar
  # algorithm to Vault. The in-memory store uses a predictable encryption
  # which is great for development and test, but should _never_ be used in
  # production. Default: ENV["VAULT_RAILS_ENABLED"].
  vault.enabled = Rails.env.production?

  # The name of the application. All encrypted keys in Vault will be
  # prefixed with this application name. If you change the name of the
  # application, you will need to migrate the encrypted data to the new
  # key namespace. Default: ENV["VAULT_RAILS_APPLICATION"].
  vault.application = 'wca-registration'

  # The address of the Vault server, also read as ENV["VAULT_ADDR"]
  vault.address = ENV.fetch('VAULT_ADDR')

  # The token to authenticate with Vault, for prod auth is done via AWS
  if Rails.env.production?
    # Assume the correct role
    # this is needed because otherwise we will assume the role of the underlying instance instead
    role_credentials = Aws::ECSCredentials.new(retries: 3)

    Vault.auth.aws_iam(ENV['TASK_ROLE'], role_credentials, nil, "https://sts.#{ENV['AWS_REGION']}.amazonaws.com")
  else
    vault.token = ENV['VAULT_DEV_ROOT_TOKEN_ID']
  end

  # Use SSL verification, also read as ENV["VAULT_SSL_VERIFY"]
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

# Read a secret from Vault.
def read_secret(secret_name)
  Vault.with_retries(Vault::HTTPConnectionError, Vault::HTTPError) do |attempt, e|
    puts "Received exception #{e} from Vault - attempt #{attempt}" if e
    secret = Vault.logical.read("secret/data/wca-registration/#{secret_name}")
    if secret.present?
      secret.data[:data][:value]
    else # TODO: should we hard error out here?
      puts "Tried to read #{secret_name}, but doesn´t exist"
    end
  end
end

def create_secret(secret_name, value)
  Vault.with_retries(Vault::HTTPConnectionError) do
    Vault.logical.write("secret/data/wca-registration/#{secret_name}", data: { value: })
  end
end

# Initialize secrets for dev and test
def init
  create_secret('SECRET_KEY_BASE',
                'a003fdc6f113ff7d295596a02192c7116a76724ba6d3071043eefdd16f05971be0dc58f244e67728757b2fb55ae7a41e1eb97c1fe247ddaeb6caa97cea32120c')
end

init unless Rails.env.production?
