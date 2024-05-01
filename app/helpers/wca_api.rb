# frozen_string_literal: true

class WcaApi
  WCA_API_HEADER = 'X-WCA-Service-Token'
  # Uses Vault ID Tokens: see https://developer.hashicorp.com/vault/docs/secrets/identity/identity-token
  def self.wca_token
    return nil unless Rails.env.production?
    Vault.with_retries(Vault::HTTPConnectionError) do
      data = Vault.logical.read("identity/oidc/token/#{EnvConfig.VAULT_APPLICATION}")
      if data.present?
        data.data[:token]
      else # TODO: should we hard error out here?
        puts 'Tried to get identity token, but got error'
      end
    end
  end
end
