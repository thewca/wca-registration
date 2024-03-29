# frozen_string_literal: true

require 'time'

class RegistrationHistory
  include Dynamoid::Document

  # We autoscale dynamodb
  table name: EnvConfig.REGISTRATION_HISTORY_DYNAMO_TABLE, capacity_mode: nil, key: :attendee_id

  field :items, :array, of: History
  # We only do this one way because Dynamoid doesn't allow us to overwrite the foreign_key for has_one
  belongs_to :registration, foreign_key: :attendee_id

  def add_entry(changed_attributes, actor_user_id)
    entry = History.new({ changed_attributes: changed_attributes, actor_user_id: actor_user_id })
    if history.empty?
      update_attributes(history: [entry])
    else
      update_attributes(history: history.append(entry))
    end
  end
end
