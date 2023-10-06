# frozen_string_literal: true

class RegistrationError < StandardError
  attr_reader :status, :error_code

  def initialize(status, error_code)
    super
    @status = status
    @error_code = error_code
  end
end
