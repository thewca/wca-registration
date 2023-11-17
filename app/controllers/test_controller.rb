# frozen_string_literal: true

require_relative '../../spec/support/dynamoid_reset'

class TestController < ApplicationController
  include DynamoidReset
  def reset
    return head :forbidden if Rails.env.production?
    DynamoidReset.all
    head :ok
  end
end
