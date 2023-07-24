# frozen_string_literal: true

require_relative './jwt_options'
class JwtHelper
  # We should actually implement this using vaults identity tokens
  def self.get_token(audience)
    iat = Time.now.to_i
    jti_raw = [JwtOptions.secret, iat].join(':').to_s
    jti = Digest::MD5.hexdigest(jti_raw)
    payload = { data: { service_id: "registration.worldcubeassociation.org" }, aud: audience, exp: Time.now.to_i + JwtOptions.expiry, sub: "registration.worldcubeassociation.org", iat: iat, jti: jti }
    JWT.encode payload, JwtOptions.secret, JwtOptions.algorithm
  end
end
