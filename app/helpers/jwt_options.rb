# frozen_string_literal: true

module JwtOptions
  class << self
    attr_accessor :secret, :algorithm, :expiry
  end
end
