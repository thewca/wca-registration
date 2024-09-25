module Competition
  def self.accepted_competitors_count(competition_id)
    Rails.cache.fetch("#{competition_id}-accepted-count", expires_in: 60.minutes, raw: true) do
      V2Registration.includes([:registration_lane]).where(competition_id: competition_id, registration_lane: { lane_state: 'accepted' }).count
    end.to_i
  end

  def self.decrement_competitors_count(competition_id)
    RedisHelper.decrement_or_initialize("#{competition_id}-accepted-count") do
      self.accepted_competitors.count
    end
  end

  def self.increment_competitors_count(competition_id)
    RedisHelper.increment_or_initialize("#{competition_id}-accepted-count") do
      self.accepted_competitors.count
    end
  end
end
