# frozen_string_literal: true

require 'jwt'
class JwtDevController < ApplicationController
  skip_before_action :validate_token, only: [:index]
  def index
    # These are all the fields that the monolith jwt tokens set from https://github.com/jwt/ruby-jwt
    user_id = params[:user_id] || "15073"
    iat = Time.now.to_i
    jti_raw = [JWTOptions.secret, iat].join(':').to_s
    jti = Digest::MD5.hexdigest(jti_raw)
    payload = { data: { user_id: user_id }, exp: Time.now.to_i + JWTOptions.expiry, sub: user_id, iat: iat, jti: jti }
    token = JWT.encode payload, JWTOptions.secret, JWTOptions.algorithm
    response.set_header("Authorization", "Bearer: #{token}")
    render json: { status: 'ok' }, status: :ok
  end
end
