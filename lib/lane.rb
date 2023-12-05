# frozen_string_literal: true

class Lane
  attr_accessor :lane_name, :lane_state, :completed_steps, :lane_details

  EVENT_IDS = %w[333 222 444 555 666 777 333bf 333oh clock minx pyram skewb sq1 444bf 555bf 333mbf 333fm].freeze

  def initialize(args)
    @lane_name = args['lane_name']
    @lane_state = args['lane_state'] || 'waiting'
    @completed_steps = args['completed_steps'] || []
    @lane_details = args['lane_details'] || {}
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

  def move_within_waiting_list(competition_id, new_position)
    if new_position < get_lane_detail('waiting_list_position')
      cascade_waiting_list(competition_id, new_position, get_lane_detail('waiting_list_position')+1)
    else
      cascade_waiting_list(competition_id, get_lane_detail('waiting_list_position'), new_position+1, -1)
    end
    set_lane_detail('waiting_list_position', new_position)
  end

  def add_to_waiting_list(competition_id)
    # TODO: Tests in lane_spec for this function?
    # TODO: Test cases for when there's actually no change to (a) the status, or (b) the waiting_list_position
    # TODO: Invalidate Finn's waiting_list cache when this function is called
    # TODO: Make sure I'm invalidating this cache appropriately
    boundaries = get_waiting_list_boundaries(competition_id)
    waiting_list_max = boundaries['waiting_list_position_max']
    waiting_list_min = boundaries['waiting_list_position_min']

    if waiting_list_max.nil? && waiting_list_min.nil?
      set_lane_detail('waiting_list_position', 1)
    else
      set_lane_detail('waiting_list_position', waiting_list_max+1)
    end
  end

  def remove_from_waiting_list(competition_id)
    max_position = get_waiting_list_boundaries(competition_id)['waiting_list_position_max']
    cascade_waiting_list(competition_id, get_lane_detail('waiting_list_position'), max_position+1, -1)
    set_lane_detail('waiting_list_position', nil)
  end

  def accept_from_waiting_list
    set_lane_detail('waiting_list_position', nil)
  end

  # NOTE: Does this belong in the lane? Or in some lib file or something?
  def get_registrations_by_status(competition_id, status)
    Rails.cache.fetch("#{competition_id}-waiting_list_registrations", expires_in: 60.minutes) do
      Registration.where(competition_id: competition_id, competing_status: status)
    end
  end

  def get_waiting_list_boundaries(competition_id)
    Rails.cache.fetch("#{competition_id}-waiting_list_boundaries", expires_in: 60.minutes) do
      waiting_list_registrations = get_registrations_by_status(competition_id, 'waiting_list')

      # Iterate through waiting list registrations and record min/max waiting list positions
      # We aren't just counting the number of registrations in the waiting list. When a registration is
      # accepted from the waiting list, we don't "move up" the waiting_list_position of the registrations
      # behind it - so we can't assume that the position 1 is the min, or that the count of waiting_list
      # registrations is the max.

      waiting_list_position_min = nil
      waiting_list_position_max = nil

      waiting_list_registrations.each do |reg|
        waiting_list_position_min = reg.competing_waiting_list_position if
          waiting_list_position_min.nil? || reg.competing_waiting_list_position < waiting_list_position_min
        waiting_list_position_max = reg.competing_waiting_list_position if
          waiting_list_position_max.nil? || reg.competing_waiting_list_position > waiting_list_position_max
      end

      {
        'waiting_list_position_min' => waiting_list_position_min,
        'waiting_list_position_max' => waiting_list_position_max,
      }
    end
  end

  # NOTE: Is this function necessary? I think so?
  def set_lane_detail(property_name, property_value)
    lane_details[property_name] = property_value
  end

  # NOTE: Is this function necessary? I think so?
  def get_lane_detail(property_name)
    lane_details[property_name]
  end

  def update_events(new_event_ids)
    if @lane_name == 'competing'
      current_event_ids = @lane_details['event_details'].pluck('event_id')

      # Update events list with new events
      new_event_ids.each do |id|
        next if current_event_ids.include?(id)
        new_details = {
          'event_id' => id,
          # NOTE: Currently event_registration_state is not used - when per-event registrations are added, we need to add validation logic to support cases like
          # limited registrations and waiting lists for certain events
          'event_registration_state' => @lane_state,
        }
        @lane_details['event_details'] << new_details
      end

      # Remove events not in the new events list
      @lane_details['event_details'].delete_if do |event|
        !(new_event_ids.include?(event['event_id']))
      end
    end
  end

  private

    # Used for propagating a change in waiting_list_position to all affected registrations
    # increment_value is the value by which position should be shifted - usually 1 or -1
    # Lower waiting_list_position = higher up the waiting list (1 on waiting list will be accepted before 10)
    def cascade_waiting_list(competition_id, start_at, stop_at, increment_value = 1)
      waiting_list_registrations = get_registrations_by_status(competition_id, 'waiting_list')

      waiting_list_registrations.each do |reg|
        current_position = reg.competing_waiting_list_position
        if current_position >= start_at && current_position < stop_at
          reg.update_competing_waiting_list_position(current_position + increment_value)
        end
      end
    end
end
