# frozen_string_literal: true

require 'jwt'
require_relative '../../spec/support/dynamoid_reset'

class TestController < ApplicationController
  include DynamoidReset
  skip_before_action :validate_token, only: [:token, :reset]
  def token
    # This route isn't actually in the routes definition on prod
    return head :forbidden if Rails.env.production?
    # These are all the fields that the monolith jwt tokens set from https://github.com/jwt/ruby-jwt
    user_id = params.require(:user_id)
    iat = Time.now.to_i
    jti_raw = [JwtOptions.secret, iat].join(':').to_s
    jti = Digest::MD5.hexdigest(jti_raw)
    payload = { user_id: user_id, exp: Time.now.to_i + JwtOptions.expiry, sub: user_id, iat: iat, jti: jti }
    token = JWT.encode payload, JwtOptions.secret, JwtOptions.algorithm
    render json: { token: token }, status: :ok
  end

  def reset
    return head :forbidden if Rails.env.production?
    DynamoidReset.all
    head :ok
  end
end
