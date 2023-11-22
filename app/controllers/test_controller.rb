# frozen_string_literal: true

class TestController < ApplicationController
  skip_before_action :validate_token, only: [:reset]

  def reset
    require_relative '../../spec/support/dynamoid_reset'
    include DynamoidReset
    return head :forbidden if Rails.env.production?
    DynamoidReset.all
    head :ok
  end
end
