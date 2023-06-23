# frozen_string_literal: true

class Lane
  attr_accessor :lane_name, :lane_state, :completed_steps, :lane_details

  def initialize(args)
    @lane_name = args["lane_name"]
    @lane_state = args["lane_state"] || "waiting"
    @completed_steps = args["completed_steps"] || []
    @lane_details = args["lane_details"] || {}
  end

  def dynamoid_dump
    self.to_json
  end

  def ==(other)
    @lane_name == other.lane_name && @lane_state == other.lane_state && @completed_steps == other.completed_steps && @lane_details == other.lane_details
  end

  def self.dynamoid_load(serialized_str)
    parsed = JSON.parse serialized_str
    Lane.new(parsed)
  end
end
