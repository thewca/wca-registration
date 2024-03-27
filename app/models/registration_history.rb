# frozen_string_literal: true

require 'time'

require_relative './registration'

class RegistrationHistory
  include Dynamoid::Document

  # We autoscale dynamodb
  table name: EnvConfig.REGISTRATION_HISTORY_DYNAMO_TABLE, capacity_mode: nil, key: :attendee_id

  field :history, :array, of: History
  belongs_to :registration, class: Registration

  def add_entry(changed_attributes, actor_user_id)
    entry = History.new({ changed_attributes: changed_attributes, actor_user_id: actor_user_id })
    if history.empty?
      update_attributes(history: [entry])
    else
      update_attributes(history: history.append(entry))
    end
  end
end
