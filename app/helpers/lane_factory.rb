# frozen_string_literal: true

require 'time'
class LaneFactory
  # TODO: try again to set waiting_list_position form the tests, instead of directly in the lane factory
  def self.competing_lane(event_ids: [], comment: '', admin_comment: '', registration_status: 'pending', waiting_list_position: nil)
    competing_lane = Lane.new({})
    competing_lane.lane_name = 'competing'
    competing_lane.completed_steps = ['Event Registration']
    competing_lane.lane_state = registration_status
    competing_lane.lane_details = {
      'event_details' => event_ids.map { |event_id| { event_id: event_id, event_registration_state: registration_status } },
      'comment' => comment,
      'admin_comment' => admin_comment,
      'waiting_list_position' => waiting_list_position.to_i,
    }
    competing_lane
  end

  def self.payment_lane(fee_lowest_denominator, currency_code, payment_id)
    payment_lane = Lane.new({})
    payment_lane.lane_name = 'payment'
    payment_lane.completed_steps = ['Payment Intent Init']
    payment_lane.lane_state = 'initialized'
    payment_lane.lane_details = {
      'amount_lowest_denominator' => fee_lowest_denominator,
      'payment_id' => payment_id,
      'currency_code' => currency_code,
      'last_updated' => Time.now,
      'payment_history' => [],
    }
    payment_lane
  end
end
