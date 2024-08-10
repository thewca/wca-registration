# frozen_string_literal: true

require 'factory_bot_rails'

FactoryBot.define do
  factory :registration do
    transient do
      events { ['333', '333mbf'] }
      comment { '' }
      guests { 0 }
      registration_status { 'incoming' }
      organizer_comment { '' }
    end

    user_id { rand(100000..200000) }
    competition_id { 'CubingZANationalChampionship2023' }
    attendee_id { "#{competition_id}-#{user_id}" }
    lanes {
      [LaneFactory.competing_lane(
        event_ids: events,
        comment: comment,
        registration_status: registration_status,
        admin_comment: organizer_comment,
      )]
    }
    history { association :registration_history, attendee_id: "#{competition_id}-#{user_id}" }
  end

  trait :waiting_list do
    registration_status { 'waiting_list' }
  end

  trait :admin do
    user_id { 15073 }
  end

  trait :organizer do
    user_id { 1 }
  end

  factory :organizer_registration, traits: [:organizer]
  factory :admin_registration, traits: [:admin]
end
