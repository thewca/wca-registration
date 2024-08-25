# frozen_string_literal: true

class WcaApi
  WCA_API_HEADER = 'X-WCA-Service-Token'
  # Uses Vault ID Tokens: see https://developer.hashicorp.com/vault/docs/secrets/identity/identity-token
  def self.wca_token
    return nil unless Rails.env.production?

    vault_token_data = Vault.auth_token.lookup_self.data
    # Renew our token if it has expired or is close to expiring
    if vault_token_data[:ttl] < 300
      Vault.auth_token.renew_self
    end

    Vault.with_retries(Vault::HTTPConnectionError) do
      data = Vault.logical.read("identity/oidc/token/#{EnvConfig.VAULT_APPLICATION}")
      if data.present?
        data.data[:token]
      else # TODO: should we hard error out here?
        Rails.logger.debug 'Tried to get identity token, but got error'
      end
    end
  end

  def self.get_request(url)
    response = HTTParty.get(url, headers: { WCA_API_HEADER => self.wca_token })
    if response.code == 200
      response
    else
      Metrics.registration_competition_api_error_counter.increment
      raise RegistrationError.new(:service_unavailable, ErrorCodes::MONOLITH_API_ERROR, { http_code: response.code, body: response.parsed_response })
    end
  end

  def self.post_request(url, body)
    response = HTTParty.post(url, headers: { WCA_API_HEADER => self.wca_token }, body: body)
    if response.code == 200
      response
    else
      Metrics.registration_competition_api_error_counter.increment
      raise RegistrationError.new(:service_unavailable, ErrorCodes::MONOLITH_API_ERROR, { http_code: response.code, body: response.parsed_response })
    end
  end
end
