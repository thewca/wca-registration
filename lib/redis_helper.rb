# frozen_string_literal: true

module RedisHelper
  def self.increment_or_initialize(key, &)
    if Rails.cache.exist?(key)
      Rails.cache.increment(key)
    else
      Rails.cache.write(key, yield, expires_in: 60.minutes, raw: true)
    end
  end

  def self.delete_user_registrations(user_id)
    Rails.cache.delete("#{user_id}-registrations-by-user")
  end

  def self.decrement_or_initialize(key, &)
    if Rails.cache.exist?(key)
      Rails.cache.decrement(key)
    else
      Rails.cache.write(key, yield, expires_in: 60.minutes, raw: true)
    end
  end

  # The Hydration block needs to return an array of hashes that have an 'id' field
  def self.cache_info_by_ids(key_prefix, ids, &)
    keys = ids.map { |id| "#{key_prefix}-#{id}" }.to_a

    info = Rails.cache.read_multi(*keys)
    uncached_ids = ids.to_a - info.values.pluck('id')

    # Don't call hydration function if we have cached all data
    unless uncached_ids.empty?
      # Get Data for all uncached ids
      hydrated_info = yield(uncached_ids)

      # Write all new data into the cache
      keys = *hydrated_info.map do |item|
        key = "#{key_prefix}-#{item['id']}"
        info[key] = item
        [key, item]
      end
      Rails.cache.write_multi(
        keys,
        expires_in: 60.minutes,
      )
    end

    info.values
  end
end
