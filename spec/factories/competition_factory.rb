# frozen_string_literal: true

require 'factory_bot_rails'

FactoryBot.define do
  factory :competition_details, class: Hash do
    transient do
      events { ["333", "222", "444", "555", "666", "777", "333bf", "333oh", "clock", "minx", "pyram", "skewb", "sq1", "444bf", "555bf", "333mbf"] }
      registration_opened? { true }
    end

    competition_id { "CubingZANationalChampionship2023" }
    name { 'CubingZA National Championship 2023' }
    event_ids { events }
    registration_open { "2023-05-05T04:00:00.000Z" }
    registration_close { "2024-06-14T00:00:00.000Z" }
    announced_at { "2023-05-01T15:59:53.000Z" }
    start_date { "2023-06-16" }
    end_date { "2023-06-18" }
    competitor_limit { 120 }
    cancelled_at { "null" }
    url { "https://www.worldcubeassociation.org/competitions/CubingZANationalChampionship2023" }
    website { "https://www.worldcubeassociation.org/competitions/CubingZANationalChampionship2023" }
    short_name { "CubingZA Nationals 2023" }
    city { "Johannesburg" }
    venue_address { "South Africa, 28 Droste Cres, Droste Park, Johannesburg, 2094" }
    venue_details { "" }
    latitude_degrees { -26.21117 }
    longitude_degrees { 28.06449 }
    country_iso2 { "ZA" }
    guest_entry_status { "restricted" }
    guests_per_registration_limit { 2 }
    event_change_deadline_date { "2024-06-14T00:00:00.000Z" }

    initialize_with { attributes }
  end
end
