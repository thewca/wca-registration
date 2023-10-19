# frozen_string_literal: true

require 'factory_bot_rails'

# TODO: Add guests (requires change to registration model)
# TODO: Refactor Lane model to be a helper class? Discuss with Finn how this should work
FactoryBot.define do
  factory :registration do
    transient do
      events { ['333', '333mbf'] }
      comment { '' }
      guests { 0 }
      lane_state { 'incoming' }
      admin_comment { nil }
    end
    user_id { '158817' }
    competition_id { 'CubingZANationalChampionship2023' }
    attendee_id { "#{competition_id}-#{user_id}" }
    lanes { [LaneFactory.competing_lane(events, comment, guests, lane_state)] }
  end

  trait :admin do
    user_id { '15073' }
  end

  trait :organizer do
    user_id { '1' }
  end

  factory :organizer_registration, traits: [:organizer]
  factory :admin_registration, traits: [:admin]

  after(:create) do |registration, evaluator|
    if evaluator.admin_comment.nil?
      puts 'admin comment is nil'
    else
      attendee_id = "#{evaluator.competition_id}-#{evaluator.user_id}"
      registration = Registration.find(attendee_id)
      registration.update_competing_lane!({ admin_comment: evaluator.admin_comment })
    end
  end
end
