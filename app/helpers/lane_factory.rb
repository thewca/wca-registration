# frozen_string_literal: true

class LaneFactory
  def self.competing_lane(event_ids = [], comment = "", guests=0)
    competing_lane = Lane.new({})
    competing_lane.lane_name = "competing"
    competing_lane.completed_steps = ["Event Registration"]
    competing_lane.lane_details = {
      event_details: event_ids.map { |event_id| { event_id: event_id } },
      comment: comment,
      guests: guests
    }
    competing_lane
  end
end
