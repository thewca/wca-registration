# frozen_string_literal: true

class WaitingList
  include Dynamoid::Document

  # We autoscale dynamodb
  table name: EnvConfig.WAITING_LIST_DYNAMO_TABLE, capacity_mode: nil, key: :id

  field :entries, :array, of: :integer

  def remove(user_id)
    update_attributes!(entries: entries - [user_id])
  end

  def add(user_id)
    if entries.nil?
      update_attributes!(entries: [user_id])
    else
      update_attributes!(entries: entries + [user_id])
    end
  end

  def move_to_position(user_id, new_position)
    raise ArgumentError.new('Target position out of waiting list range') if new_position > entries.length || new_position < 1

    old_index = entries.find_index(user_id)
    return if old_index == new_position-1

    update_attributes!(entries: entries.insert(new_position-1, entries.delete_at(old_index)))
  end

  def self.find_or_create!(id)
    puts("called find from #{caller[0..2]}")
    WaitingList.find(id)
  rescue Dynamoid::Errors::RecordNotFound
    WaitingList.create(id: id, entries: [])
  end
end
