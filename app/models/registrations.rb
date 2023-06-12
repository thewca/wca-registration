# frozen_string_literal: true

require_relative 'lane'
class Registrations
  include Dynamoid::Document

  # We autoscale dynamodb in production
  if ENV.fetch("CODE_ENVIRONMENT", "development") == "staging"
    table name: 'registrations-staging', read_capacity: 5, write_capacity: 5, key: :attendee_id
  else
    table name: "registrations", capacity_mode: nil, key: :attendee_id
  end

  # Fields
  field :user_id, :string
  field :competition_id, :string
  field :is_attending, :boolean
  field :hide_name_publicly, :boolean
  field :lane_states, :map
  field :lanes, :array, of: Lane

  global_secondary_index hash_key: :user_id, projected_attributes: :all
  global_secondary_index hash_key: :competition_id, projected_attributes: :all
end
