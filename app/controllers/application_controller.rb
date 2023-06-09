# frozen_string_literal: true

require_relative '../helpers/error_codes'
class ApplicationController < ActionController::API
  prepend_before_action :validate_token
  around_action :performance_profile if Rails.env == 'development'
  def validate_token
    auth_header = request.headers["Authorization"]
    unless auth_header.present?
      return render json: { error: ErrorCodes::MISSING_AUTHENTICATION }, status: :forbidden
    end
    token = request.headers["Authorization"].split[1]
    begin
      decoded_token = (JWT.decode token, JwtOptions.secret, true, { algorithm: JwtOptions.algorithm })[0]
      @current_user = decoded_token["data"]["user_id"]
    rescue JWT::VerificationError, JWT::InvalidJtiError
      Metrics.jwt_verification_error_counter.increment
      render json: { error: ErrorCodes::INVALID_TOKEN }, status: :forbidden
    rescue JWT::ExpiredSignature
      render json: { error: ErrorCodes::EXPIRED_TOKEN }, status: :forbidden
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
