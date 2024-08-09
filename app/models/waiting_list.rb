# frozen_string_literal: true

class WaitingList
  include Dynamoid::Document

  # We autoscale dynamodb
  table name: EnvConfig.WAITING_LIST_DYNAMO_TABLE, capacity_mode: nil, key: :id

  field :entries, :array, of: :integer

  def remove_competitor(competitor_id)
    update_attributes!(entries: entries - [competitor_id])
  end

  def add_competitor(competitor_id)
    if entries.nil?
      update_attributes!(entries: [competitor_id])
    else
      update_attributes!(entries: entries + [competitor_id])
    end
  end

  def move_competitor(competitor_id, new_index)
    old_index = entries.find_index(competitor_id)
    Rails.logger.debug(entries.inspect)
    update_attributes!(entries: entries.insert(old_index, entries.delete_at(new_index)))
  end
end
