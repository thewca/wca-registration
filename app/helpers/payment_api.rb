# frozen_string_literal: true

require_relative 'error_codes'
require_relative 'wca_api'
require_relative 'mocks'
class PaymentApi < WcaApi
  def self.get_ticket(attendee_id, amount, currency_code)
    token = self.get_wca_token("payments.worldcubeassociation.org")
    response = HTTParty.post("https://test-registration.worldcubeassociation.org/api/v10/payment/init",
                             body: { "attendee_id" => attendee_id, "amount" => amount, "currency_code" => currency_code }.to_json,
                             headers: { 'Authorization' => "Bearer: #{token}",
                                        "Content-Type" => "application/json" })
    unless response.ok?
      raise "Error from the payments service"
    end
    [response["client_secret"], response["connected_account_id"]]
  end
end
