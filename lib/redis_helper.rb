# frozen_string_literal: true

module RedisHelper
  def self.update(key, &block)
    Rails.cache.write(key, block.call, expires_in: 60.minutes)
  end
end
