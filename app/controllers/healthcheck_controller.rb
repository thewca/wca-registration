# frozen_string_literal: true

class HealthcheckController < ApplicationController
  def index
    render json: { status: 'ok' }, status: :ok
  end
end
