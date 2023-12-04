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
    # old_position = get_lane_details_property('waiting_list_position')
    if new_position < get_lane_details_property('waiting_list_position')
      increment_waiting_list_from_position_to_position(competition_id, new_position, get_lane_details_property('waiting_list_position'))
    else
      decrement_waiting_list_from_position_to_position(competition_id, get_lane_details_property('waiting_list_position'), new_position)
    end
    set_lane_details_property('waiting_list_position', new_position)
  end

  def add_to_waiting_list(competition_id)
    puts 'adding to waiting list'
    # TODO: Tests in lane_spec for this function?
    # TODO: Test cases for when there's actually no change to (a) the status, or (b) the waiting_list_position
    # TODO: Invalidate Finn's waiting_list cache when this function is called
    # TODO: Make sure I'm invalidating this cache appropriately
    boundaries = get_waiting_list_boundaries(competition_id)
    waiting_list_max = boundaries['waiting_list_position_max']
    waiting_list_min = boundaries['waiting_list_position_min']

    if waiting_list_max.nil? && waiting_list_min.nil?
      set_lane_details_property('waiting_list_position', 1)
    else
      set_lane_details_property('waiting_list_position', waiting_list_max+1)
    end
  end

  def remove_from_waiting_list(competition_id)
    puts 'removing from waiting list'
    decrement_waiting_list_from_position(competition_id, get_lane_details_property('waiting_list_position'))
    set_lane_details_property('waiting_list_position', nil)
  end

  def increment_waiting_list_from_position_to_position(competition_id, from_position, to_position)
    waiting_list_registrations = get_registrations_by_status(competition_id, 'waiting_list')

    waiting_list_registrations.each do |reg|
      current_position = reg.competing_waiting_list_position
      if current_position >= from_position && current_position < to_position
        # reg.competing_lane.set_lane_details_property('waiting_list_position', current_position-1)
        reg.update_competing_waiting_list_position(current_position+1)
      end
    end
  end

  def decrement_waiting_list_from_position_to_position(competition_id, from_position, to_position)
    puts 'decrementing range'
    waiting_list_registrations = get_registrations_by_status(competition_id, 'waiting_list')

    waiting_list_registrations.each do |reg|
      current_position = reg.competing_waiting_list_position
      if current_position > from_position && current_position <= to_position
        puts "decrementing position: #{current_position}"
        # reg.competing_lane.set_lane_details_property('waiting_list_position', current_position-1)
        reg.update_competing_waiting_list_position(current_position-1)
      end
    end
  end

  # Any item with waiting_list_position > given position will be decremented on the waiting list
  def decrement_waiting_list_from_position(competition_id, position)
    waiting_list_registrations = get_registrations_by_status(competition_id, 'waiting_list')

    waiting_list_registrations.each do |reg|
      current_position = reg.competing_waiting_list_position
      if current_position > position
        # reg.competing_lane.set_lane_details_property('waiting_list_position', current_position-1)
        reg.update_competing_waiting_list_position(current_position-1)
      end
    end
  end

  def accept_from_waiting_list
    puts 'accepting from waiting list'
    set_lane_details_property('waiting_list_position', nil)
  end

  def get_registrations_by_status(competition_id, status)
    Rails.cache.fetch("#{competition_id}-waiting_list_registrations", expires_in: 60.minutes) do
      Registration.where(competition_id: competition_id, competing_status: status)
    end
  end

  def get_waiting_list_boundaries(competition_id)
    # TODO: Tests in lane_spec for this function?
    Rails.cache.fetch("#{competition_id}-waiting_list_boundaries", expires_in: 60.minutes) do
      # TODO: Make sure I'm invalidating this cache appropriately
      # Get all registrations with correct competition_id with status of waiting_list
      waiting_list_registrations = get_registrations_by_status(competition_id, 'waiting_list')

      # Iterate through waiting list registrations and record min/max waiting list positions
      # We aren't just counting the number of registrations in the waiting list, as that may not necessarily match the boundary positions
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

  # def set_lane_details_property('waiting_list_position', waiting_list_position)
  #   lane_details['waiting_list_position'] = waiting_list_position
  # end

  def set_lane_details_property(property_name, property_value)
    lane_details[property_name] = property_value
  end

  def get_lane_details_property(property_name)
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
end
