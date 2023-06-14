# frozen_string_literal: true

class Lane
  attr_accessor :name, :lane_state, :completed_steps, :step_details

  def initialize(args)
    @name = args["name"]
    @lane_state = args["lane_state"] || "waiting"
    @completed_steps = args["completed_steps"] || []
    @step_details = args["step_details"] || {}
  end

  def dynamoid_dump
    self.to_json
  end

  def self.dynamoid_load(serialized_str)
    parsed = JSON.parse serialized_str
    Lane.new(parsed)
  end
end
