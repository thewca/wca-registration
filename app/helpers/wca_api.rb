# frozen_string_literal: true

class WcaApi
  WCA_API_HEADER = 'X-WCA-Service-Token'
  # Uses Vault ID Tokens: see https://developer.hashicorp.com/vault/docs/secrets/identity/identity-token
  def self.get_wca_token
    Vault.with_retries(Vault::HTTPConnectionError) do
      data = Vault.logical.read("identity/oidc/token/#{@vault_application}")
      if data.present?
        data.data[:data][:token]
      else # TODO: should we hard error out here?
        puts 'Tried to get identity token, but got error'
      end
    end
  end
end
