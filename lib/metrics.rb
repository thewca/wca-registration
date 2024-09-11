# frozen_string_literal: true

module Metrics
  def self.increment(metric)
    return if Rails.env.local?
    ::NewRelic::Agent.increment_metric(metric)
  end
end
