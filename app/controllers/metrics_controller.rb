# frozen_string_literal: true

require 'securerandom'
class MetricsController < ApplicationController
  def index
    # Get the queue attributes
    queue_url = $sqs.get_queue_url(queue_name: 'registrations.fifo').queue_url
    response = $sqs.get_queue_attributes({
                                           queue_url:,
                                           attribute_names: ['ApproximateNumberOfMessages']
                                         })

    # Get the queue size
    queue_size = response.attributes['ApproximateNumberOfMessages'].to_i

    render json: { queue_size: }
  end
end
