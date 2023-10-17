# frozen_string_literal: true

require 'factory_bot_rails'

# Couldn't get the import from a support folder to work, so defining directly in the factory file
def fetch_jwt_token(user_id)
  iat = Time.now.to_i
  jti_raw = [JwtOptions.secret, iat].join(':').to_s
  jti = Digest::MD5.hexdigest(jti_raw)
  payload = { data: { user_id: user_id }, exp: Time.now.to_i + JwtOptions.expiry, sub: user_id, iat: iat, jti: jti }
  token = JWT.encode payload, JwtOptions.secret, JwtOptions.algorithm
  "Bearer #{token}"
end

# TODOS
# x1. Fetch the user_id variable to create JWT token
# 1. Create an admin option
# 2. Figre out how to change values with arguments
# 3 Create a separate competing lane and add that to the registration?

FactoryBot.define do
  factory :registration, class: Hash do
    transient do
      events { ['333', '333mbf'] }
    end

    user_id { '158817' }
    competition_id { 'CubingZANationalChampionship2023' }
    competing { { event_ids: events, lane_state: 'pending' } }
    jwt_token { fetch_jwt_token(user_id) }

    trait :admin do
      user_id { '15073' }
      jwt_token { fetch_jwt_token(user_id) }
    end

    trait :admin_submits do
      jwt_token { fetch_jwt_token('15073') }
    end

    trait :impersonation do
      jwt_token { fetch_jwt_token('1000') }
    end

    trait :banned do
      user_id { '209943' }
    end

    trait :incomplete do
      user_id { '999999' }
    end

    trait :guests do
      guests { 2 }
    end

    initialize_with { attributes }

    factory :registration_for_admin, traits: [:admin]
    factory :admin_submits_registration_for_user, traits: [:admin_submits]
    factory :impersonation, traits: [:impersonation]
    factory :registration_with_guests, traits: [:guests]
    factory :banned_competitor, traits: [:banned]
    factory :incomplete_profile, traits: [:incomplete]
  end
end
