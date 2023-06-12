# frozen_string_literal: true

class LaneFactory
  def self.competing_lane
    # TODO: How do I directly initialize this here??
    competing_lane = Lane.new({})
    competing_lane.name = "Competing"
    competing_lane
  end
end
