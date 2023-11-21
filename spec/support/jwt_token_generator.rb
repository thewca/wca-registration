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
