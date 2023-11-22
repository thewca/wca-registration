# frozen_string_literal: true

class TestController < ApplicationController
  skip_before_action :validate_token, only: [:reset]

  def reset
    unless Rails.env.production?
      require_relative '../../spec/support/dynamoid_reset'
      DynamoidReset.all
      return head :ok
    end
    head :forbidden
  end
end
