# frozen_string_literal: true

require 'time'

class InternalController < ApplicationController
  prepend_before_action :validate_token

  def validate_token
    service_token = request.headers['X-WCA-Service-Token']
    unless service_token.present?
      return render json: { error: "Missing Authentication" }, status: :forbidden
    end
    # The Vault CLI can't parse the response from identity/oidc/introspect so
    # we need to request it instead see https://github.com/hashicorp/vault/issues/9080

    vault_token_data = Vault.auth_token.lookup_self.data
    # Renew our token if it has expired or is close to expiring
    if vault_token_data[:ttl] < 300
      Vault.auth_token.renew_self
    end

    # Make the POST request to the introspect endpoint
    response = HTTParty.post("#{EnvConfig.VAULT_ADDR}/v1/identity/oidc/introspect",
                             body: { token: service_token }.to_json,
                             headers: { 'X-Vault-Token' => vault_token_data[:id],
                                        'Content-Type' => 'application/json' })
    if response.ok?
      unless response["active"]
        render json: { error: "Authentication Expired or Token Invalid" }, status: :forbidden
      end
    else
      raise "Introspection failed with the following error: #{response.status}, #{response.body}"
    end
  end

  def update_payment_status
    attendee_id = params.require(:attendee_id)
    payment_id = params.require(:payment_id)
    iso_amount = params.require(:iso_amount)
    currency_iso = params.require(:currency_iso)
    payment_status = params.require(:payment_status)
    registration = Registration.find(attendee_id)
    registration.update_payment_lane(payment_id, iso_amount, currency_iso, payment_status)
    render json: { status: "ok" }
  end
end