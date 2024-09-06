# frozen_string_literal: true

class ErrorsController < ApplicationController
  def show
    exception = request.env["action_dispatch.exception"]
    status_code = ActionDispatch::ExceptionWrapper.new(request.env, exception).status_code
    request_id = request.env["action_dispatch.request_id"]
    render json: { error: ErrorCodes::INTERNAL_SERVER_ERROR, request_id: request_id }, status: status_code
  end
end