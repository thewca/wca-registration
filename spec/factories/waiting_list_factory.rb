# frozen_string_literal: true

require 'factory_bot_rails'

FactoryBot.define do
  factory :waiting_list do
    id { 'CubingZANationalChampionship2023' }
    entries { [] }
  end
end
