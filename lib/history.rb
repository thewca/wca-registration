# frozen_string_literal: true

class History
  attr_accessor :changed_attributes, :actor_user_id, :time_stamp

  def initialize(args)
    @changed_attributes = args['changed_attributes'] || {}
    @actor_user_id = args['actor_user_id'] || ''
    @time_stamp = args['timestamp'] || Time.now
  end

  def dynamoid_dump
    self.to_json
  end

  def self.dynamoid_load(serialized_str)
    parsed = JSON.parse serialized_str
    History.new(parsed)
  end
end
