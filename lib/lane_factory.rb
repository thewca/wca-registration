# frozen_string_literal: true

require 'time'
class LaneFactory
  # TODO: try again to set waiting_list_position form the tests, instead of directly in the lane factory
  def self.competing_lane(event_ids: [], comment: '', admin_comment: '', registration_status: 'pending', waiting_list_position: nil)
    {
      lane_name: 'competing',
      completed_steps: ['Event Registration'],
      lane_state: registration_status,
      lane_details: {
        'event_details' => event_ids.map { |event_id| { event_id: event_id, event_registration_state: registration_status } },
        'comment' => comment,
        'admin_comment' => admin_comment,
        'waiting_list_position' => waiting_list_position.to_i,
      }
    }
  end

  def self.payment_lane(fee_lowest_denominator, currency_code, payment_id, donation)
    {
      lane_name: 'payment',
      completed_steps: ['Payment Intent Init'],
      lane_state: 'initialized',
      lane_details: {
        'amount_lowest_denominator' => fee_lowest_denominator,
        'payment_id' => payment_id,
        'currency_code' => currency_code,
        'last_updated' => Time.now.utc,
        'payment_history' => [],
        'donation_lowest_denominator' => donation,
      }
    }
  end
end
