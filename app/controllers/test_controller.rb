# frozen_string_literal: true

require_relative '../../spec/support/dynamoid_reset'

class TestController < ApplicationController
  include DynamoidReset
  def reset
    return head :forbidden unless Rails.env.test?
    DynamoidReset.all
    head :ok
  end
end
