# frozen_string_literal: true

class LaneFactory
  def self.competing_lane(event_ids = [], comment = '', guests = 0)
    competing_lane = Lane.new({})
    competing_lane.lane_name = 'competing'
    competing_lane.completed_steps = ['Event Registration']
    competing_lane.lane_state = 'pending'
    competing_lane.lane_details = {
      event_details: event_ids.map { |event_id| { event_id: event_id } },
      comment: comment,
      guests: guests,
    }
    competing_lane
  end

  def self.payment_lane(fee_lowest_denominator, currency_code, payment_id)
    payment_lane = Lane.new({})
    payment_lane.lane_name = 'payment'
    payment_lane.completed_steps = ['Payment Intent Init']
    payment_lane.lane_state = 'initialized'
    payment_lane.lane_details = {
      amount_lowest_denominator: fee_lowest_denominator,
      payment_intent_client_secret: payment_id,
      currency_code: currency_code,
    }
    payment_lane
  end
end
