# frozen_string_literal: true

require 'time'

class RegistrationHistory
  include Dynamoid::Document

  # We autoscale dynamodb
  table name: EnvConfig.REGISTRATION_HISTORY_DYNAMO_TABLE, capacity_mode: nil, key: :attendee_id

  field :entries, :array, of: History

  def add_entry(changed_attributes, actor_user_id)
    entry = History.new({ 'changed_attributes' => changed_attributes, 'actor_user_id' => actor_user_id })
    if entries.empty?
      update_attributes(entries: [entry])
    else
      update_attributes(entries: entries.append(entry))
    end
  end
end
