# frozen_string_literal: true

class ApplicationController < ActionController::API
  prepend_before_action :validate_jwt_token
  around_action :performance_profile if Rails.env.development?
  def validate_jwt_token
    auth_header = request.headers['Authorization']
    if auth_header.blank?
      return render json: { error: ErrorCodes::MISSING_AUTHENTICATION }, status: :unauthorized
    end
    token = request.headers['Authorization'].split[1]
    begin
      decoded_token = (JWT.decode token, JwtOptions.secret, true, { algorithm: JwtOptions.algorithm })[0]
      @current_user = decoded_token['user_id'].to_i
    rescue JWT::VerificationError, JWT::InvalidJtiError
      Metrics.jwt_verification_error_counter.increment
      render json: { error: ErrorCodes::INVALID_TOKEN }, status: :unauthorized
    rescue JWT::ExpiredSignature
      render json: { error: ErrorCodes::EXPIRED_TOKEN }, status: :unauthorized
    end
  end

  def performance_profile(&)
    if params[:profile] && (result = RubyProf.profile(&))

      out = StringIO.new
      RubyProf::GraphHtmlPrinter.new(result).print out, min_percent: 0
      response.set_header('Content-Type', 'text/html')
      response.body = out.string
    else
      yield
    end
  end

  def render_error(http_status, error)
    Metrics.registration_validation_errors_counter.increment
    render json: { error: error }, status: http_status
  end

  rescue_from ActionController::ParameterMissing do |e|
    render json: { error: ErrorCodes::INVALID_REQUEST_DATA }, status: :bad_request
  end
end
