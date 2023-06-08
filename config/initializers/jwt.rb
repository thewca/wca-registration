# frozen_string_literal: true

require_relative '../../app/helpers/jwt_options'

JWTOptions.secret = read_secret('JWT_SECRET')
# Default algorithm for Devise-jwt
JWTOptions.algorithm = 'HS256'
