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
  def initialize(date = '2024-07-08')
    @date = date
    @qualification_results = [
      ['222', 'single', '200', @date],
      ['333', 'single', '900', @date],
      ['pyra', 'single', '1625', @date],
      ['555', 'average', '5000', @date],
      ['555bf', 'average', '189700', @date],
      ['minx', 'average', '13887', @date],
    ]
  end
end

def qualifications(qualification_args) 
  qualification_args.map do |q|
    qualification_data(q[0], q[1], q[2], q[3])
  end
end

private def qualification_data(event, type, time, date)
  {
    eventId: event,
    type: type,
    best: time,
    on_or_before: date,
  }
end
