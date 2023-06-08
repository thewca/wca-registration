# frozen_string_literal: true

module JWTOptions
  class << self
    attr_accessor :secret, :algorithm
  end
end
