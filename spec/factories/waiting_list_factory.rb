# frozen_string_literal: true

require 'factory_bot_rails'

FactoryBot.define do
  factory :waiting_list do
    transient do
      populate { nil }
    end

    id { 'CubingZANationalChampionship2023' }
    entries { [] }

    after(:create) do |waiting_list, evaluator|
      unless evaluator.populate.nil?
        registrations = FactoryBot.create_list(:registration, evaluator.populate, registration_status: 'waiting_list')
        registrations.each { |r| waiting_list.add(r.user_id) }
      end
    end
  end
end
