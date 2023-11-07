# frozen_string_literal: true

require_relative 'lane'
require 'time'
class Registration
  include Dynamoid::Document

  # We autoscale dynamodb
  table name: EnvConfig.DYNAMO_REGISTRATIONS_TABLE, capacity_mode: nil, key: :attendee_id

  REGISTRATION_STATES = %w[pending waiting_list accepted cancelled].freeze
  ADMIN_ONLY_STATES = %w[pending waiting_list accepted].freeze # Only admins are allowed to change registration state to one of these states

  # Returns all event ids irrespective of registration status
  def event_ids
    lanes.filter_map { |x| x.lane_details['event_details'].pluck('event_id') if x.lane_name == 'competing' }[0]
  end

  # Returns id's of the events with a non-cancelled state
  def registered_event_ids
    event_ids = []

    competing_lane = lanes.find { |x| x.lane_name == 'competing' }

    competing_lane.lane_details['event_details'].each do |event|
      if event['event_registration_state'] != 'cancelled'
        event_ids << event['event_id']
      end
    end
    event_ids
  end

  def event_details
    competing_lane = lanes.find { |x| x.lane_name == 'competing' }
    competing_lane.lane_details['event_details']
  end

  def competing_status
    lanes.filter_map { |x| x.lane_state if x.lane_name == 'competing' }[0]
  end

  def competing_comment
    lanes.filter_map { |x| x.lane_details['comment'] if x.lane_name == 'competing' }[0]
  end

  def competing_guests
    lanes.filter_map { |x| x.lane_details['guests'] if x.lane_name == 'competing' }[0]
  end

  # TODO: Change this when we introduce a guest lane
  def guests
    lanes.filter_map { |x| x.lane_details['guests'] if x.lane_name == 'competing' }[0]
  end

  def admin_comment
    lanes.filter_map { |x| x.lane_details['admin_comment'] if x.lane_name == 'competing' }[0]
  end

  def payment_ticket
    lanes.filter_map { |x| x.lane_details['payment_id'] if x.lane_name == 'payment' }[0]
  end

  def payment_status
    lanes.filter_map { |x| x.lane_state if x.lane_name == 'payment' }[0]
  end

  def payment_date
    lanes.filter_map { |x| x.lane_details['last_updated'] if x.lane_name == 'payment' }[0]
  end

  def payment_history
    lanes.filter_map { |x| x.lane_details['payment_history'] if x.lane_name == 'payment' }[0]
  end

  def update_competing_lane!(update_params)
    updated_lanes = lanes.map do |lane|
      if lane.lane_name == 'competing'

        # Update status for lane and events
        if update_params[:status].present?
          lane.lane_state = update_params[:status]

          lane.lane_details['event_details'].each do |event|
            # NOTE: Currently event_registration_state is not used - when per-event registrations are added, we need to add validation logic to support cases like
            # limited registrations and waiting lists for certain events
            event['event_registration_state'] = update_params[:status]
          end
        end

        lane.lane_details['comment'] = update_params[:comment] if update_params[:comment].present?
        lane.lane_details['guests'] = update_params[:guests] if update_params[:guests].present?
        lane.lane_details['admin_comment'] = update_params[:admin_comment] if update_params[:admin_comment].present?
        if update_params[:event_ids].present? && update_params[:status] != 'cancelled'
          lane.update_events(update_params[:event_ids])
        end
      end
      lane
    end
    # TODO: In the future we will need to check if any of the other lanes have a status set to accepted
    updated_is_attending = if update_params[:status].present?
                             update_params[:status] == 'accepted'
                           else
                             is_attending
                           end
    update_attributes!(lanes: updated_lanes, is_attending: updated_is_attending) # TODO: Apparently update_attributes is deprecated in favor of update! - should we change?
  end

  def init_payment_lane(amount, currency_code, id)
    payment_lane = LaneFactory.payment_lane(amount, currency_code, id)
    update_attributes(lanes: lanes.append(payment_lane))
  end

  def update_payment_lane(id, iso_amount, currency_iso, status)
    updated_lanes = lanes.map do |lane|
      if lane.lane_name == 'payment'
        old_details = lane.lane_details
        # TODO: Should we only add payments to the payment_history
        # if there is a new payment_id?
        lane.lane_details['payment_history'].append({
                                                      status: lane.lane_state,
                                                      payment_id: old_details['payment_id'],
                                                      currency_code: old_details['currency_code'],
                                                      amount_lowest_denominator: old_details['amount_lowest_denominator'],
                                                      last_updated: old_details['last_updated'],
                                                    })
        lane.lane_state = status
        lane.lane_details['payment_id'] = id
        lane.lane_details['amount_lowest_denominator'] = iso_amount
        lane.lane_details['currency_code'] = currency_iso
        lane.lane_details['last_updated'] = Time.now
      end
      lane
    end
    update_attributes!(lanes: updated_lanes)
  end

  # Fields
  field :user_id, :string
  field :competition_id, :string
  # field :guests, :integer
  field :is_attending, :boolean
  field :hide_name_publicly, :boolean
  field :lanes, :array, of: Lane

  global_secondary_index hash_key: :user_id, projected_attributes: :all
  global_secondary_index hash_key: :competition_id, projected_attributes: :all
end
