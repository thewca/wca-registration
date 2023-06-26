# frozen_string_literal: true

class HealthcheckController < ApplicationController
  skip_before_action :validate_token, only: [:index]
  def index
    render json: { status: 'ok' }, status: :ok
  end
end
