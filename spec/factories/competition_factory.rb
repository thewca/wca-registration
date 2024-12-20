# frozen_string_literal: true

require 'factory_bot_rails'

FactoryBot.define do
  factory :competition, class: Hash do
    events { ['333', '222', '444', '555', '666', '777', '333bf', '333oh', 'clock', 'minx', 'pyram', 'skewb', 'sq1', '444bf', '555bf', '333mbf'] }
    id { 'CubingZANationalChampionship2023' }
    name { 'CubingZA National Championship 2023' }
    event_ids { events }
    registration_open { '2023-05-05T04:00:00.000Z' }
    registration_close { 1.week.from_now.iso8601 }
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
    qualifications { nil }
    qualification_results { false }
    allow_registration_without_qualification { false }
    guest_entry_status { 'restricted' }
    guests_per_registration_limit { 2 }
    event_change_deadline_date { 1.week.from_now.iso8601 }
    events_per_registration_limit { 'null' }
    using_payment_integrations? { true }
    competition_series_ids { nil }
    force_comment_in_registration { false }
    allow_registration_self_delete_after_acceptance { true }
    allow_registration_edits { true }
    delegates { [{ 'id' => 1306 }] }
    organizers { [] }

    initialize_with { attributes.stringify_keys }

    trait :no_guest_limit do
      guest_entry_status { 'free' }
      guests_per_registration_limit { nil }
    end

    trait :has_qualifications do
      today = Time.now.utc.iso8601

      transient do
        extra_qualifications { {} }
        standard_qualifications {
          {
            '333' => { 'type' => 'attemptResult', 'resultType' => 'single', 'whenDate' => today, 'level' => 1000 },
            '555' => { 'type' => 'attemptResult', 'resultType' => 'average', 'whenDate' => today, 'level' => 6000 },
            'pyram' => { 'type' => 'ranking', 'resultType' => 'single', 'whenDate' => (Time.now.utc-2).iso8601, 'level' => 100 },
            'minx' => { 'type' => 'ranking', 'resultType' => 'average', 'whenDate' => today, 'level' => 200 },
            '222' => { 'type' => 'anyResult', 'resultType' => 'single', 'whenDate' => today, 'level' => 0 },
            '555bf' => { 'type' => 'anyResult', 'resultType' => 'average', 'whenDate' => today, 'level' => 0 },
          }
        }
      end

      qualifications { standard_qualifications.merge(extra_qualifications) }
      qualification_results { true }
      allow_registration_without_qualification { false }
    end

    trait :has_future_qualifications do
      tomorrow = (Time.now.utc+1).iso8601

      transient do
        extra_qualifications { {} }
        standard_qualifications {
          {
            '333' => { 'type' => 'attemptResult', 'resultType' => 'single', 'whenDate' => tomorrow, 'level' => 1000 },
            '555' => { 'type' => 'attemptResult', 'resultType' => 'average', 'whenDate' => tomorrow, 'level' => 6000 },
            'pyram' => { 'type' => 'ranking', 'resultType' => 'single', 'whenDate' => tomorrow, 'level' => 100 },
            'minx' => { 'type' => 'ranking', 'resultType' => 'average', 'whenDate' => tomorrow, 'level' => 200 },
            '222' => { 'type' => 'anyResult', 'resultType' => 'single', 'whenDate' => tomorrow, 'level' => 0 },
            '555bf' => { 'type' => 'anyResult', 'resultType' => 'average', 'whenDate' => tomorrow, 'level' => 0 },
          }
        }
      end

      qualifications { standard_qualifications.merge(extra_qualifications) }
      qualification_results { true }
      allow_registration_without_qualification { false }
    end

    trait :has_hard_qualifications do
      today = Time.now.utc.iso8601

      transient do
        extra_qualifications { {} }
        standard_qualifications {
          {
            '333' => { 'type' => 'attemptResult', 'resultType' => 'single', 'whenDate' => today, 'level' => 10 },
            '555' => { 'type' => 'attemptResult', 'resultType' => 'average', 'whenDate' => today, 'level' => 60 },
            'pyram' => { 'type' => 'ranking', 'resultType' => 'single', 'whenDate' => (Time.now.utc-3.days).iso8601, 'level' => 10 },
            'minx' => { 'type' => 'ranking', 'resultType' => 'average', 'whenDate' => (Time.now.utc-3.days).iso8601, 'level' => 20 },
            '222' => { 'type' => 'anyResult', 'resultType' => 'single', 'whenDate' => (Time.now.utc-3.days).iso8601, 'level' => 0 },
            '555bf' => { 'type' => 'anyResult', 'resultType' => 'average', 'whenDate' => (Time.now.utc-3.days).iso8601, 'level' => 0 },
          }
        }
      end

      qualifications { standard_qualifications.merge(extra_qualifications) }
      qualification_results { true }
      allow_registration_without_qualification { false }
    end

    trait :qualifications_not_enforced do
      allow_registration_without_qualification { true }
    end

    trait :closed do
      registration_open { '2023-05-05T04:00:00.000Z' }
      registration_close { 1.week.ago.iso8601 }
      registration_currently_open? { false }
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
  end
end
