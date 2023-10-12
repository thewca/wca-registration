# frozen_string_literal: true

require_relative 'error_codes'
require_relative 'wca_api'
class PaymentApi < WcaApi
  def self.get_ticket(attendee_id, amount, currency_code)
    response = HTTParty.post(payment_init_path,
                             body: { "attendee_id" => attendee_id, "amount" => amount, "currency_code" => currency_code }.to_json,
                             headers: { WCA_API_HEADER => self.get_wca_token,
                                        "Content-Type" => "application/json" })
    unless response.ok?
      raise "Error from the payments service"
    end
    response["id"]
  end

  private

    def payment_init_path
      "#{WCA_HOST}/api/internal/v1/payment/init"
    end
end
