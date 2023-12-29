# frozen_string_literal: true

class BulkUpdateError < StandardError
  attr_reader :http_status, :errors

  def initialize(http_status, errors)
    @http_status = http_status
    @errors = errors
  end
end
