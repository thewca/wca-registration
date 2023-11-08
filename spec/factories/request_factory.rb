# frozen_string_literal: true

require 'factory_bot_rails'

# Couldn't get the import from a support folder to work, so defining directly in the factory file
def fetch_jwt_token(user_id)
  iat = Time.now.to_i
  jti_raw = [JwtOptions.secret, iat].join(':').to_s
  jti = Digest::MD5.hexdigest(jti_raw)
  payload = { user_id: user_id, exp: Time.now.to_i + JwtOptions.expiry, sub: user_id, iat: iat, jti: jti }
  token = JWT.encode payload, JwtOptions.secret, JwtOptions.algorithm
  "Bearer #{token}"
end

# TODOS
# 3 Create a separate competing lane and add that to the registration_request?

FactoryBot.define do
  factory :registration_request, class: Hash do
    transient do
      events { ['333', '333mbf'] }
      raw_comment { nil }
    end

    user_id { '158817' }
    submitted_by { user_id }
    competition_id { 'CubingZANationalChampionship2023' }
    competing { { event_ids: events, lane_state: 'pending' } }

    jwt_token { fetch_jwt_token(submitted_by) }
    guests { 0 }

    trait :comment do
      competing { { event_ids: events, comment: raw_comment, lane_state: 'pending' } }
    end

    trait :admin do
      user_id { '15073' }
      jwt_token { fetch_jwt_token(user_id) }
    end

    trait :admin_submits do
      submitted_by { '15073' }
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

    initialize_with { attributes }

    factory :registration_request_for_admin, traits: [:admin]
    factory :admin_submits_registration_request_for_user, traits: [:admin_submits]
    factory :admin_submits_registration_request_for_banned_user, traits: [:admin_submits, :banned]
    factory :admin_submits_registration_request_for_incomplete_user, traits: [:admin_submits, :incomplete]
    factory :impersonation, traits: [:impersonation]
    factory :banned_competitor, traits: [:banned]
    factory :incomplete_profile, traits: [:incomplete]
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

    trait :admin_as_user do
      user_id { '15073' }
    end

    trait :admin_for_user do
      submitted_by { '15073' }
    end

    trait :organizer_for_self do
      user_id { '1' }
    end

    trait :organizer_for_user do
      submitted_by { '1' }
    end

    trait :for_another_user do
      submitted_by { '158818' }
    end

    initialize_with { attributes }

    after(:build) do |instance, evaluator|
      instance[:guests] = evaluator.guests if evaluator.guests
      instance[:competing] = evaluator.competing if evaluator.competing
    end
  end
end
