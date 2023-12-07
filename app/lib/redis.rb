# frozen_string_literal: true

module Redis
  def increment_or_initialize(key, &block)
    if Rails.cache.exist?(key)
      Rails.cache.increment(key)
    else
      Rails.cache.write(key, block.call, expires_in: 60.minutes, raw: true)
    end
  end

  def decrement_or_initialize(key, &block)
    if Rails.cache.exist?(key)
      Rails.cache.decrement(key)
    else
      Rails.cache.write(key, block.call, expires_in: 60.minutes, raw: true)
    end
  end
end
