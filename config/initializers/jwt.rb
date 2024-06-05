# frozen_string_literal: true

Rails.application.config.to_prepare do
  JwtOptions.secret = AppSecrets.JWT_SECRET
  # Default algorithm for Devise-jwt
  JwtOptions.algorithm = 'HS256'
  # The expiry time we define in the monolith
  JwtOptions.expiry = 30.minutes
end
