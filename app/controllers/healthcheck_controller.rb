# frozen_string_literal: true

class HealthcheckController < ApplicationController
  skip_before_action :validate_token, only: [:index]
  def index
    render json: { status: 'ok', version: EnvConfig.BUILD_TAG }, status: :ok
  end
end
