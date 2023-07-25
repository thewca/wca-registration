# frozen_string_literal: true

require_relative 'error_codes'
class PaymentApi
  def self.get_ticket(attendee_id, amount, currency_code)
    token = JwtHelper.get_token("payments.worldcubeassociation.org")
    response = HTTParty.post("https://test-registration.worldcubeassociation.org/api/v10/internal/payments/init",
                             body: { "attendee_id" => attendee_id, "amount" => amount, "currency_code" => currency_code }.to_json,
                             headers: { 'Authorization' => "Bearer: #{token}",
                                        "Content-Type" => "application/json" })
    unless response.ok?
      raise "Error from the payments service"
    end
    response["client_secret"]
  end
end
