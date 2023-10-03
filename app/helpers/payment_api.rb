# frozen_string_literal: true

require_relative 'error_codes'
require_relative 'wca_api'
class PaymentApi < WcaApi
  def self.get_ticket(attendee_id, amount, currency_code)
    self.get_wca_token
    response = HTTParty.post("https://test-registration.worldcubeassociation.org/api/v10/payment/init",
                             body: { "attendee_id" => attendee_id, "amount" => amount, "currency_code" => currency_code }.to_json,
                             headers: { 'X-WCA-Service-Token' => "token",
                                        "Content-Type" => "application/json" })
    unless response.ok?
      puts response
      raise "Error from the payments service"
    end
    [response["client_secret"], response["connected_account_id"]]
  end
end
