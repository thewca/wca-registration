# frozen_string_literal: true

class WcaApi
  def get_wca_token
    iat = Time.now.to_i
    jti_raw = [JwtOptions.secret, iat].join(':').to_s
    jti = Digest::MD5.hexdigest(jti_raw)
    payload = { data: { service_id: "registration.worldcubeassociation.org" }, aud: "users.worldcubeassociation.org", exp: Time.now.to_i + JwtOptions.expiry, sub: "registration.worldcubeassociation.org", iat: iat, jti: jti }
    JWT.encode payload, JwtOptions.secret, JwtOptions.algorithm
  end
end
