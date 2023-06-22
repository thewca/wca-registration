# frozen_string_literal: true

class LaneFactory
  def self.competing_lane(event_ids = [], comment = "")
    competing_lane = Lane.new({})
    competing_lane.name = "Competing"
    if event_ids != []
      competing_lane.completed_steps = ["Event Registration"]
      competing_lane.step_details = {
        event_ids: event_ids,
        comment: comment,
      }
    end
    competing_lane
  end
end
