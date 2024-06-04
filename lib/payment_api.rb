# frozen_string_literal: true

class PaymentApi < WcaApi
  def self.get_ticket(attendee_id, amount, currency_code, current_user)
    response = HTTParty.post(payment_init_path,
                             body: { 'attendee_id' => attendee_id, 'amount' => amount, 'currency_code' => currency_code, 'current_user' => current_user }.to_json,
                             headers: { WCA_API_HEADER => self.wca_token,
                                        'Content-Type' => 'application/json' })
    unless response.ok?
      raise 'Error from the payments service'
    end
    [response['client_secret'], response['id']]
  end

  class << self
    def payment_init_path
      "#{EnvConfig.WCA_HOST}/api/internal/v1/payment/init_stripe"
    end
  end
end
