# frozen_string_literal: true

require_relative 'lane'
class Registration
  include Dynamoid::Document

  # We autoscale dynamodb in production
  if ENV.fetch("CODE_ENVIRONMENT", "development") == "staging"
    table name: 'registrations-staging', read_capacity: 5, write_capacity: 5, key: :attendee_id
  else
    table name: "registrations", capacity_mode: nil, key: :attendee_id
  end

  def event_ids
    lanes.filter_map { |x| x.lane_details["event_details"].pluck("event_id") if x.lane_name == "competing" }[0]
  end

  def competing_status
    lanes.filter_map { |x| x.lane_state if x.lane_name == "competing" }[0]
  end

  def competing_comment
    lanes.filter_map { |x| x.lane_details["comment"] if x.lane_name == "competing" }[0]
  end

  # TODO: Change this when we introduce a guest lane
  def guests
    lanes.filter_map { |x| x.lane_details["guests"] if x.lane_name == "competing" }[0]
  end

  def admin_comment
    lanes.filter_map { |x| x.lane_details["admin_comment"] if x.lane_name == "competing" }[0]
  end

  def update_competing_lane!(update_params)
    updated_lanes = lanes.map do |lane|
      if lane.lane_name == "competing"
        lane.lane_state = update_params[:status] if update_params[:status].present?
        lane.lane_details["comment"] = update_params[:comment] if update_params[:comment].present?
        lane.lane_details["guests"] = update_params[:guests] if update_params[:guests].present?
        lane.lane_details["admin_comment"] = update_params[:admin_comment] if update_params[:admin_comment].present?
        lane.lane_details["event_details"] = update_params[:event_ids].map { |event_id| { event_id: event_id } } if update_params[:event_ids].present?
      end
      lane
    end
    # TODO: In the future we will need to check if any of the other lanes have a status set to accepted
    updated_is_attending = if update_params[:status].present?
                             update_params[:status] == "accepted"
                           else
                             is_attending
                           end
    update_attributes!(lanes: updated_lanes, is_attending: updated_is_attending)
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
