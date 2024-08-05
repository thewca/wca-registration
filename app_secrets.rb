# frozen_string_literal: true

require 'superconfig'

require_relative 'env_config'

SuperConfig::Base.class_eval do
  # The skeleton is stolen from the source code of the `superconfig` gem, file lib/superconfig.rb:104
  #   (method SuperConfig::Base#credential). The inner Vault fetching logic is custom-written :)
  def vault(secret_name, &block)
    define_singleton_method(secret_name) do
      @__cache__["_vault_#{secret_name}"] ||= begin
        value = self.vault_read(secret_name)[:value]
        block ? block.call(value) : value
      end
    end
  end

  private def vault_read(secret_name)
    Vault.with_retries(Vault::HTTPConnectionError, Vault::HTTPError) do |attempt, e|
      puts "Received exception #{e} from Vault - attempt #{attempt}" if e.present?

      secret = Vault.logical.read("kv/data/#{EnvConfig.VAULT_APPLICATION}/#{secret_name}")
      raise "Tried to read #{secret_name}, but doesn't exist" if secret.blank?

      secret.data[:data]
    end
  end
end

AppSecrets = SuperConfig.new do
  if Rails.env.production?
    require_relative 'vault_config'

    vault :JWT_SECRET
    vault :SECRET_KEY_BASE
    vault :NEW_RELIC_LICENSE_KEY

  else
    mandatory :JWT_SECRET, :string
    mandatory :SECRET_KEY_BASE, :string
  end
end
