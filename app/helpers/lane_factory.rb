# frozen_string_literal: true

class LaneFactory
  def self.competing_lane(event_ids = {})
    competing_lane = Lane.new({})
    competing_lane.name = "Competing"
    if event_ids != {}
      competing_lane.completed_steps = ["Event Registration"]
      competing_lane.lane_details = {
        event_details: event_ids.map { |event| { event_id: event_ids } },
      }
    end
    competing_lane
  end
end
