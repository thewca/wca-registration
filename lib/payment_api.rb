# frozen_string_literal: true

class PaymentApi < WcaApi
  def self.get_ticket(attendee_id, amount, currency_code, current_user)
    response = self.post_request(
      payment_init_path,
      { 'attendee_id' => attendee_id, 'amount' => amount, 'currency_code' => currency_code, 'current_user' => current_user }.to_json,
    )
    [response['client_secret'], response['id']]
  end

  class << self
    def payment_init_path
      "#{EnvConfig.WCA_HOST}/api/internal/v1/payment/init_stripe"
    end
  end
end
