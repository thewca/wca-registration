# frozen_string_literal: true

class RegistrationError < StandardError
  attr_reader :http_status, :error, :data

  def initialize(http_status, error, data=nil)
    @http_status = http_status
    @error = error
    @data = data
  end
end
