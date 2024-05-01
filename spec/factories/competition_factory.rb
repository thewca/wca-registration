# frozen_string_literal: true

require 'factory_bot_rails'
require_relative '../../app/helpers/competition_api'

FactoryBot.define do
  factory :competition, class: Hash do
    events { ['333', '222', '444', '555', '666', '777', '333bf', '333oh', 'clock', 'minx', 'pyram', 'skewb', 'sq1', '444bf', '555bf', '333mbf'] }
    registration_opened? { true }
    id { 'CubingZANationalChampionship2023' }
    name { 'CubingZA National Championship 2023' }
    event_ids { events }
    registration_open { '2023-05-05T04:00:00.000Z' }
    registration_close { '2024-06-14T00:00:00.000Z' }
    announced_at { '2023-05-01T15:59:53.000Z' }
    start_date { '2023-06-16' }
    end_date { '2023-06-18' }
    competitor_limit { 120 }
    cancelled_at { nil }
    url { 'https://www.worldcubeassociation.org/competitions/CubingZANationalChampionship2023' }
    website { 'https://www.worldcubeassociation.org/competitions/CubingZANationalChampionship2023' }
    short_name { 'CubingZA Nationals 2023' }
    city { 'Johannesburg' }
    venue_address { 'South Africa, 28 Droste Cres, Droste Park, Johannesburg, 2094' }
    venue_details { '' }
    latitude_degrees { -26.21117 }
    longitude_degrees { 28.06449 }
    country_iso2 { 'ZA' }
    guest_entry_status { 'restricted' }
    guests_per_registration_limit { 2 }
    event_change_deadline_date { '2024-06-14T00:00:00.000Z' }
    events_per_registration_limit { 'null' }
    using_stripe_payments? { true }
    competition_series_ids { nil }
    force_comment_in_registration { false }
    allow_registration_self_delete_after_acceptance { true }
    allow_registration_edits { true }
    delegates { [{ 'id' => 1306 }] }
    organizers { [] }

    initialize_with { attributes.stringify_keys }

    transient do
      mock_competition { false }
    end

    trait :no_guest_limit do
      guest_entry_status { 'free' }
      guests_per_registration_limit { nil }
    end

    trait :not_open_yet do
      registration_opened? { false }
      event_change_deadline_date { '2022-06-14T00:00:00.000Z' }
    end

    trait :event_change_deadline_passed do
      event_change_deadline_date { '2022-06-14T00:00:00.000Z' }
    end

    trait :no_guests do
      guest_entry_status { '' }
    end

    trait :series do
      competition_series_ids { ['CubingZANationalChampionship2023', 'CubingZAWarmup2023'] }
    end

    # TODO: Create a flag that returns either the raw JSON (for mocking) or a CompetitionInfo object
    after(:create) do |competition, evaluator|
      stub_request(:get, comp_api_url(competition['competition_id'])).to_return(status: evalutor.mocked_status_code, body: competition) if evaluator.mock_competition
    end
  end
end
