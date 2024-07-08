# frozen_string_literal: true

require 'factory_bot_rails'

def fetch_jwt_token(user_id)
  iat = Time.now.to_i
  jti_raw = [JwtOptions.secret, iat].join(':').to_s
  jti = Digest::MD5.hexdigest(jti_raw)
  payload = { user_id: user_id, exp: Time.now.to_i + JwtOptions.expiry, sub: user_id, iat: iat, jti: jti }
  token = JWT.encode payload, JwtOptions.secret, JwtOptions.algorithm
  "Bearer #{token}"
end

class QualificationResultsFaker
  attr_accessor :qualification_results

  def initialize(
    date = '2024-07-08', 
    results_inputs = [
      ['222', 'single', '200'],
      ['333', 'single', '900'],
      ['pyram', 'single', '1625'],
      ['555', 'average', '5000'],
      ['555bf', 'average', '189700'],
      ['minx', 'average', '13887'],
    ]
  )
    @date = date
    @qualification_results = results_inputs.map do |input| 
      qualification_data(input[0], input[1], input[2], @date)
    end
  end

  def qualification_data(event, type, time, date)
    {
      eventId: event,
      type: type,
      best: time,
      on_or_before: date,
    }
  end
end

def qualifications(qualification_args) 
  qualification_args.map do |q|
    qualification_data(q[0], q[1], q[2], q[3])
  end
end


