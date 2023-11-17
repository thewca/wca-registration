# frozen_string_literal: true

require 'factory_bot_rails'
require_relative '../support/jwt_token_generator'

FactoryBot.define do
  factory :registration_request, class: Hash do
    transient do
      events { ['333', '333mbf'] }
      raw_comment { nil }
    end

    user_id { '158817' }
    submitted_by { user_id }
    competition_id { 'CubingZANationalChampionship2023' }
    competing { { 'event_ids' => events, 'lane_state' => 'pending' } }

    jwt_token { fetch_jwt_token(submitted_by) }
    guests { 0 }

    trait :comment do
      competing { { 'event_ids' => events, 'comment' => raw_comment, 'lane_state' => 'pending' } }
    end

    trait :organizer do
      user_id { '1306' }
      jwt_token { fetch_jwt_token(user_id) }
    end

    trait :organizer_submits do
      submitted_by { '1306' }
    end

    trait :impersonation do
      submitted_by { '158810' }
    end

    trait :banned do
      user_id { '209943' }
    end

    trait :incomplete do
      user_id { '999999' }
    end

    initialize_with { attributes.stringify_keys }
  end
end

FactoryBot.define do
  factory :update_request, class: Hash do
    user_id { '158817' }
    submitted_by { user_id }
    jwt_token { fetch_jwt_token(submitted_by) }
    competition_id { 'CubingZANationalChampionship2023' }

    transient do
      competing { nil }
      guests { nil }
    end

    trait :organizer_as_user do
      user_id { '1306' }
    end

    trait :organizer_for_user do
      submitted_by { '1306' }
    end

    trait :for_another_user do
      submitted_by { '158818' }
    end

    # initialize_with { attributes }
    initialize_with { attributes.stringify_keys }

    after(:build) do |instance, evaluator|
      instance['guests'] = evaluator.guests if evaluator.guests
      instance['competing'] = evaluator.competing if evaluator.competing
    end
  end
end