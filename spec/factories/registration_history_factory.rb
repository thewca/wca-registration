# frozen_string_literal: true

require 'factory_bot_rails'

FactoryBot.define do
  factory :registration_history do
    entries { [] }
  end
end
