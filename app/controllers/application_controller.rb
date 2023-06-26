# frozen_string_literal: true

class ApplicationController < ActionController::API
  before_action :validate_token
  around_action :performance_profile if Rails.env == 'development'

  INVALID_TOKEN_STATUS_CODE = -2
  EXPIRED_TOKEN_STATUS_CODE = -2

  def validate_token
    auth_header = request.headers["Authorization"]
    unless auth_header.present?
      return render json: { status: 'No Authentication Header Provided' }, status: :forbidden
    end
    token = request.headers["Authorization"].split[1]
    begin
      @decoded_token = (JWT.decode token, JWTOptions.secret, true, { algorithm: JWTOptions.algorithm })[0]
    rescue JWT::VerificationError, JWT::InvalidJtiError
      Metrics.jwt_verification_error_counter.increment
      render json: { status: INVALID_TOKEN_STATUS_CODE, message: 'Invalid token' }, status: :forbidden
    rescue JWT::ExpiredSignature
      render json: { status: EXPIRED_TOKEN_STATUS_CODE, message: "Authentication Expired" }, status: :forbidden
    end
  end

  def performance_profile(&)
    if params[:profile] && (result = RubyProf.profile(&))

      out = StringIO.new
      RubyProf::GraphHtmlPrinter.new(result).print out, min_percent: 0
      response.set_header("Content-Type", "text/html")
      response.body = out.string
    else
      yield
    end
  end
end
