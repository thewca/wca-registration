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

FactoryBot.define do
  factory :registration, class: Hash do
    # reg_hash {
    #   {
    #     user_id: "158817",
    #     competition_id: "CubingZANationalChampionship2023",
    #     competing: {
    #       event_ids: ["333", "333mbf"],
    #       registration_status: "pending",
    #     },
    #   }
    # }
    user_id { "158817" }
    competition_id { "CubingZANationalChampionship2023" }
    competing { { event_ids: ["333", "333mbf"], lane_state: "pending" } }
    jwt_token { fetch_jwt_token("158817") }

    initialize_with { attributes }
  end
end
