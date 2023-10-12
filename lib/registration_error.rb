# frozen_string_literal: true

class RegistrationError < StandardError
  attr_reader :http_status, :error

  def initialize(http_status, error)
    @http_status = http_status
    @error = error
  end
end
