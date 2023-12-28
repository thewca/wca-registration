# frozen_string_literal: true

module Mocks
  def self.date_from_now(months, days = 0)
    if months > 0
      return Date.today.next_month(months).next_day(days).to_s
    end
    Date.today.prev_month(months).next_day(days).to_s
  end

  def self.pii_mock(user_ids)
    user_ids.map { |u| { "user_id" => u,  "dob" => "1993-01-01", "email" => "#{u}@worldcubeassociation.org" } }
  end

  def self.permissions_mock(user_id)
    case user_id
    when '1' # Test Organizer
      {
        'can_attend_competitions' => {
          'scope' => '*',
        },
        'can_organize_competitions' => {
          'scope' => %w[CubingZANationalChampionship2023 LowLimit2023],
        },
        'can_administer_competitions' => {
          'scope' => %w[CubingZANationalChampionship2023 LowLimit2023],
        },
      }
    when '2' # Test Multi-Comp Organizer
      {
        'can_attend_competitions' => {
          'scope' => '*',
        },
        'can_organize_competitions' => {
          'scope' => %w[LazarilloOpen2023 CubingZANationalChampionship2023 KoelnerKubing2023 LowLimit2023],
        },
        'can_administer_competitions' => {
          'scope' => %w[LazarilloOpen2023 CubingZANationalChampionship2023 KoelnerKubing2023 LowLimit2023],
        },
      }
    when '15073', '15074' # Test Admin
      {
        'can_attend_competitions' => {
          'scope' => '*',
        },
        'can_organize_competitions' => {
          'scope' => '*',
        },
        'can_administer_competitions' => {
          'scope' => '*',
        },
      }
    when '209943', '999999' # Test banned/incomplete profile User
      {
        'can_attend_competitions' => {
          'scope' => [],
        },
        'can_organize_competitions' => {
          'scope' => [],
        },
        'can_administer_competitions' => {
          'scope' => [],
        },
      }
    else # Default value for test competitors
      {
        'can_attend_competitions' => {
          'scope' => '*',
        },
        'can_organize_competitions' => {
          'scope' => [],
        },
        'can_administer_competitions' => {
          'scope' => [],
        },
      }
    end
  end

  def self.mock_competition(competition_id)
    case competition_id
    when 'KoelnerKubing2023'
      {
        'id' => 'KoelnerKubing2023',
        'name' => 'Kölner Kubing 2023',
        'information' => '',
        'venue' => 'Pfarrheim St. Engelbert',
        'contact' =>
          '[Kölner Kubing 2023 Orgateam](mailto:koelnerkubing@googlegroups.com)',
        'registration_open' => self.date_from_now(-1, 1),
        'registration_close' => self.date_from_now(2),
        'use_wca_registration' => true,
        'announced_at' => '2023-08-22T17:10:32.000Z',
        'base_entry_fee_lowest_denomination' => 1600,
        'currency_code' => 'EUR',
        'start_date' => self.date_from_now(2),
        'end_date' => self.date_from_now(2, 1),
        'enable_donations' => true,
        'competitor_limit' => 100,
        'extra_registration_requirements' => '',
        'on_the_spot_registration' => false,
        'on_the_spot_entry_fee_lowest_denomination' => nil,
        'refund_policy_percent' => 100,
        'refund_policy_limit_date' => self.date_from_now(2),
        'guests_entry_fee_lowest_denomination' => 300,
        'qualification_results' => false,
        'external_registration_page' => '',
        'event_restrictions' => false,
        'cancelled_at' => nil,
        'waiting_list_deadline_date' => self.date_from_now(2, 1),
        'event_change_deadline_date' => self.date_from_now(2, 1),
        'guest_entry_status' => 'free',
        'allow_registration_edits' => true,
        'allow_registration_self_delete_after_acceptance' => false,
        'allow_registration_without_qualification' => false,
        'guests_per_registration_limit' => nil,
        'force_comment_in_registration' => false,
        'url' => 'https://www.worldcubeassociation.org/competitions/KoelnerKubing2023',
        'website' =>
          'https://www.worldcubeassociation.org/competitions/KoelnerKubing2023',
        'short_name' => 'Kölner Kubing 2023',
        'city' => 'Köln',
        'venue_address' => 'Pfarrer-Moll-Str. 54, 51105 Cologne, Germany',
        'venue_details' => 'Obergeschoss // upstairs',
        'latitude_degrees' => 50.929833,
        'longitude_degrees' => 6.995431,
        'country_iso2' => 'DE',
        'event_ids' => %w[333 222 444 555 666 777 333fm 333oh clock pyram skewb],
        'registration_opened?' => true,
        'main_event_id' => '333',
        'number_of_bookmarks' => 66,
        'using_stripe_payments?' => nil,
        'uses_qualification?' => false,
        'uses_cutoff?' => true,
        'delegates' => [
          {
            'id' => 2,
          },
        ],
        'organizers' => [
          {
            'id' => 80_119,
          },
        ],
        'tabs' => [
          {
            'id' => 31_963,
          },
        ],
        'class' => 'competition',
      }
    when 'LowLimit2023'
      {
        'id' => 'LowLimit2023',
        'name' => 'Low Limit 2023',
        'information' => '',
        'venue' => 'Pfarrheim St. Engelbert',
        'contact' =>
          '[Kölner Kubing 2023 Orgateam](mailto:koelnerkubing@googlegroups.com)',
        'registration_open' => self.date_from_now(-1, 1),
        'registration_close' => self.date_from_now(2),
        'use_wca_registration' => true,
        'announced_at' => '2023-08-22T17:10:32.000Z',
        'base_entry_fee_lowest_denomination' => 1600,
        'currency_code' => 'EUR',
        'start_date' => self.date_from_now(2),
        'end_date' => self.date_from_now(2, 1),
        'enable_donations' => true,
        'competitor_limit' => 3,
        'extra_registration_requirements' => '',
        'on_the_spot_registration' => false,
        'on_the_spot_entry_fee_lowest_denomination' => nil,
        'refund_policy_percent' => 100,
        'refund_policy_limit_date' => self.date_from_now(2),
        'guests_entry_fee_lowest_denomination' => 300,
        'qualification_results' => false,
        'external_registration_page' => '',
        'event_restrictions' => false,
        'cancelled_at' => nil,
        'waiting_list_deadline_date' => self.date_from_now(2, 1),
        'event_change_deadline_date' => self.date_from_now(2, 1),
        'guest_entry_status' => 'free',
        'allow_registration_edits' => true,
        'allow_registration_self_delete_after_acceptance' => false,
        'allow_registration_without_qualification' => false,
        'guests_per_registration_limit' => nil,
        'force_comment_in_registration' => false,
        'url' => 'https://www.worldcubeassociation.org/competitions/KoelnerKubing2023',
        'website' =>
          'https://www.worldcubeassociation.org/competitions/KoelnerKubing2023',
        'short_name' => 'Kölner Kubing 2023',
        'city' => 'Köln',
        'venue_address' => 'Pfarrer-Moll-Str. 54, 51105 Cologne, Germany',
        'venue_details' => 'Obergeschoss // upstairs',
        'latitude_degrees' => 50.929833,
        'longitude_degrees' => 6.995431,
        'country_iso2' => 'DE',
        'event_ids' => %w[333 222 444 555 666 777 333fm 333oh clock pyram skewb],
        'registration_opened?' => true,
        'main_event_id' => '333',
        'number_of_bookmarks' => 66,
        'using_stripe_payments?' => nil,
        'uses_qualification?' => false,
        'uses_cutoff?' => true,
        'delegates' => [
          {
            'id' => 2,
          },
        ],
        'organizers' => [
          {
            'id' => 80_119,
          },
        ],
        'tabs' => [
          {
            'id' => 31_963,
          },
        ],
        'class' => 'competition',
      }
    when 'FMCFrance2023'
      {
        'id' => 'FMCFrance2023',
        'name' => 'FMC France 2023',
        'information' => '',
        'venue' => 'Lieux multiples / Multiple locations',
        'contact' => '',
        'registration_open' => self.date_from_now(-1),
        'registration_close' => self.date_from_now(0, 2),
        'use_wca_registration' => true,
        'announced_at' => '2023-10-11T21:56:10.000Z',
        'base_entry_fee_lowest_denomination' => 500,
        'currency_code' => 'EUR',
        'start_date' => '2023-11-18',
        'end_date' => '2023-11-18',
        'enable_donations' => true,
        'competitor_limit' => nil,
        'extra_registration_requirements' => '',
        'on_the_spot_registration' => true,
        'on_the_spot_entry_fee_lowest_denomination' => 500,
        'refund_policy_percent' => 100,
        'refund_policy_limit_date' => self.date_from_now(0, 2),
        'guests_entry_fee_lowest_denomination' => 0,
        'qualification_results' => false,
        'external_registration_page' => '',
        'event_restrictions' => false,
        'cancelled_at' => nil,
        'waiting_list_deadline_date' => self.date_from_now(0, 1),
        'event_change_deadline_date' => self.date_from_now(0, 1),
        'guest_entry_status' => 'free',
        'allow_registration_edits' => false,
        'allow_registration_self_delete_after_acceptance' => true,
        'allow_registration_without_qualification' => false,
        'guests_per_registration_limit' => nil,
        'force_comment_in_registration' => true,
        'url' => 'https://www.worldcubeassociation.org/competitions/FMCFrance2023',
        'website' => 'https://www.worldcubeassociation.org/competitions/FMCFrance2023',
        'short_name' => 'FMC France 2023',
        'city' => 'Lieux multiples / Multiple locations',
        'venue_address' => 'Lieux multiples / Multiple locations',
        'venue_details' => '',
        'latitude_degrees' => 46.53924,
        'longitude_degrees' => 2.430189,
        'country_iso2' => 'FR',
        'event_ids' => ['333fm'],
        'registration_opened?' => true,
        'main_event_id' => '333fm',
        'number_of_bookmarks' => 20,
        'using_stripe_payments?' => false,
        'uses_qualification?' => false,
        'uses_cutoff?' => false,
        'delegates' => [
          {
            'id' => 1436,
          },
        ],
        'organizers' => [
          {
            'id' => 1436,
          },
        ],
        'tabs' => [
          {
            'id' => 34_420,
          },
        ],
        'class' => 'competition',
      }
    when 'RheinNeckarAutumn2023'
      {
        'id' => 'RheinNeckarAutumn2023',
        'name' => 'Rhein-Neckar Autumn 2023',
        'information' => '',
        'venue' => 'Sonnbergschule',
        'contact' => 'rheinneckarorga@gmail.com',
        'registration_open' => self.date_from_now(-1),
        'registration_close' => self.date_from_now(1),
        'use_wca_registration' => true,
        'announced_at' => '2023-07-30T11:14:17.000Z',
        'base_entry_fee_lowest_denomination' => 1000,
        'currency_code' => 'EUR',
        'start_date' => self.date_from_now(1, 1),
        'end_date' => self.date_from_now(1, 1),
        'enable_donations' => false,
        'competitor_limit' => 150,
        'extra_registration_requirements' => '',
        'on_the_spot_registration' => false,
        'on_the_spot_entry_fee_lowest_denomination' => nil,
        'refund_policy_percent' => 100,
        'refund_policy_limit_date' => self.date_from_now(1),
        'guests_entry_fee_lowest_denomination' => 0,
        'qualification_results' => false,
        'external_registration_page' => '',
        'event_restrictions' => false,
        'cancelled_at' => nil,
        'waiting_list_deadline_date' => self.date_from_now(1),
        'event_change_deadline_date' => nil,
        'guest_entry_status' => 'free',
        'allow_registration_edits' => true,
        'allow_registration_self_delete_after_acceptance' => false,
        'allow_registration_without_qualification' => false,
        'guests_per_registration_limit' => nil,
        'force_comment_in_registration' => false,
        'url' =>
          'https://www.worldcubeassociation.org/competitions/RheinNeckarAutumn2023',
        'website' =>
          'https://www.worldcubeassociation.org/competitions/RheinNeckarAutumn2023',
        'short_name' => 'Rhein-Neckar Autumn 2023',
        'city' => 'Laudenbach',
        'venue_address' => 'Schillerstraße 6, 69514 Laudenbach, Deutschland',
        'venue_details' =>
          'On the first floor in the back, reachable through a metal staircase at the outside of the building.',
        'latitude_degrees' => 49.61296,
        'longitude_degrees' => 8.6508,
        'country_iso2' => 'DE',
        'event_ids' => %w[333 444 555 666 777 333bf 333oh clock minx skewb sq1],
        'registration_opened?' => true,
        'main_event_id' => '333',
        'number_of_bookmarks' => 102,
        'using_stripe_payments?' => true,
        'uses_qualification?' => false,
        'uses_cutoff?' => true,
        'delegates' => [
          {
            'id' => 49_811,
          },
        ],
        'organizers' => [
          {
            'id' => 7063,
          },
        ],
        'tabs' => [
          {
            'id' => 30_361,
          },
        ],
        'class' => 'competition',
      }
    when 'HessenOpen2023'
      {
        'id' => 'HessenOpen2023',
        'name' => 'Hessen Open 2023',
        'information' => '',
        'venue' => 'Bürgerhaus Hofheim',
        'contact' => '[Orga-Team](mailto:Hessen-Open@gmx.de)',
        'registration_open' => '2023-02-25T18:00:00.000Z',
        'registration_close' => '2023-05-13T18:00:00.000Z',
        'use_wca_registration' => true,
        'announced_at' => '2023-02-16T17:38:45.000Z',
        'base_entry_fee_lowest_denomination' => 500,
        'currency_code' => 'EUR',
        'start_date' => '2023-05-20',
        'end_date' => '2023-05-21',
        'enable_donations' => false,
        'competitor_limit' => 90,
        'extra_registration_requirements' => '',
        'on_the_spot_registration' => false,
        'on_the_spot_entry_fee_lowest_denomination' => nil,
        'refund_policy_percent' => 100,
        'refund_policy_limit_date' => '2023-05-13T18:00:00.000Z',
        'guests_entry_fee_lowest_denomination' => 0,
        'qualification_results' => false,
        'external_registration_page' => '',
        'event_restrictions' => false,
        'cancelled_at' => nil,
        'waiting_list_deadline_date' => '2023-05-14T18:00:00.000Z',
        'event_change_deadline_date' => '2023-05-13T18:00:00.000Z',
        'guest_entry_status' => 'free',
        'allow_registration_edits' => true,
        'allow_registration_self_delete_after_acceptance' => false,
        'allow_registration_without_qualification' => false,
        'guests_per_registration_limit' => nil,
        'force_comment_in_registration' => false,
        'url' => 'https://www.worldcubeassociation.org/competitions/HessenOpen2023',
        'website' => 'https://www.worldcubeassociation.org/competitions/HessenOpen2023',
        'short_name' => 'Hessen Open 2023',
        'city' => 'Lampertheim-Hofheim',
        'venue_address' => 'Balthasar-Neumann-Straße 1-3 68623 Lampertheim',
        'venue_details' => '',
        'latitude_degrees' => 49.660638,
        'longitude_degrees' => 8.414024,
        'country_iso2' => 'DE',
        'event_ids' => %w[333 444 555 333bf 333fm 333oh clock minx pyram skewb sq1 333mbf],
        'registration_opened?' => false,
        'main_event_id' => '333',
        'number_of_bookmarks' => 51,
        'using_stripe_payments?' => nil,
        'uses_qualification?' => false,
        'uses_cutoff?' => true,
        'delegates' => [
          {
            'id' => 7139,
          },
        ],
        'organizers' => [
          {
            'id' => 6247,
          },
        ],
        'tabs' => [
          {
            'id' => 24_368,
          },
        ],
        'class' => 'competition',
      }
    when 'ManchesterSpring2024'
      {
        'id' => 'ManchesterSpring2024',
        'name' => 'Manchester Spring 2024',
        'information' => '',
        'venue' => 'Wythenshawe Forum',
        'contact' => '',
        'registration_open' => self.date_from_now(1),
        'registration_close' => self.date_from_now(2),
        'use_wca_registration' => true,
        'announced_at' => '2023-09-12T21:59:02.000Z',
        'base_entry_fee_lowest_denomination' => 4000,
        'currency_code' => 'GBP',
        'start_date' => self.date_from_now(3),
        'end_date' => self.date_from_now(3, 1),
        'enable_donations' => false,
        'competitor_limit' => 120,
        'extra_registration_requirements' => '',
        'on_the_spot_registration' => false,
        'on_the_spot_entry_fee_lowest_denomination' => nil,
        'refund_policy_percent' => 75,
        'refund_policy_limit_date' => self.date_from_now(2),
        'guests_entry_fee_lowest_denomination' => 0,
        'qualification_results' => false,
        'external_registration_page' => '',
        'event_restrictions' => false,
        'cancelled_at' => nil,
        'waiting_list_deadline_date' => self.date_from_now(2),
        'event_change_deadline_date' => self.date_from_now(2),
        'guest_entry_status' => 'unclear',
        'allow_registration_edits' => true,
        'allow_registration_self_delete_after_acceptance' => false,
        'allow_registration_without_qualification' => false,
        'guests_per_registration_limit' => nil,
        'force_comment_in_registration' => false,
        'url' =>
          'https://www.worldcubeassociation.org/competitions/ManchesterSpring2024',
        'website' =>
          'https://www.worldcubeassociation.org/competitions/ManchesterSpring2024',
        'short_name' => 'Manchester Spring 2024',
        'city' => 'Manchester, Greater Manchester',
        'venue_address' => 'Forum Centre, Simonsway, Wythenshawe, Manchester M22 5RX',
        'venue_details' => 'Forum Hall',
        'latitude_degrees' => 53.379712,
        'longitude_degrees' => -2.265415,
        'country_iso2' => 'GB',
        'event_ids' => %w[333 222 444 555 666 777 333bf 333fm 333oh clock minx pyram skewb sq1 444bf 555bf 333mbf],
        'registration_opened?' => false,
        'main_event_id' => '333',
        'number_of_bookmarks' => 100,
        'using_stripe_payments?' => false,
        'uses_qualification?' => false,
        'uses_cutoff?' => true,
        'delegates' => [
          {
            'id' => 2,
          },
        ],
        'organizers' => [
          {
            'id' => 6858,
          },
        ],
        'tabs' => [
          {
            'id' => 33_677,
          },
        ],
        'class' => 'competition',
      }
    when 'PickeringFavouritesAutumn2023'
      {
        'id' => 'PickeringFavouritesAutumn2023',
        'name' => 'Pickering Favourites Autumn 2023',
        'information' => '',
        'venue' =>
          '[Chestnut Hill Developments Recreation Complex](https://www.pickering.ca/en/living/LocationPRC.aspx)',
        'contact' => 'info+pickering-favourites-autumn-2023@speedcubingcanada.org',
        'registration_open' => self.date_from_now(-3),
        'registration_close' => self.date_from_now(1),
        'use_wca_registration' => true,
        'announced_at' => '2023-07-23T23:22:13.000Z',
        'base_entry_fee_lowest_denomination' => 3500,
        'currency_code' => 'CAD',
        'start_date' => '2023-12-16',
        'end_date' => '2023-12-16',
        'enable_donations' => false,
        'competitor_limit' => 160,
        'extra_registration_requirements' => '',
        'on_the_spot_registration' => false,
        'on_the_spot_entry_fee_lowest_denomination' => nil,
        'refund_policy_percent' => 95,
        'refund_policy_limit_date' => self.date_from_now(0, 1),
        'guests_entry_fee_lowest_denomination' => 0,
        'qualification_results' => false,
        'external_registration_page' => '',
        'event_restrictions' => true,
        'cancelled_at' => nil,
        'waiting_list_deadline_date' => self.date_from_now(0, 1),
        'event_change_deadline_date' => self.date_from_now(0, -1),
        'guest_entry_status' => 'restricted',
        'allow_registration_edits' => true,
        'allow_registration_self_delete_after_acceptance' => false,
        'allow_registration_without_qualification' => true,
        'guests_per_registration_limit' => 1,
        'force_comment_in_registration' => false,
        'url' =>
          'https://www.worldcubeassociation.org/competitions/PickeringFavouritesAutumn2023',
        'website' =>
          'https://www.worldcubeassociation.org/competitions/PickeringFavouritesAutumn2023',
        'short_name' => 'Pickering Favourites Autumn 2023',
        'city' => 'Pickering, Ontario',
        'venue_address' => '1867 Valley Farm Road, Pickering, ON',
        'venue_details' => 'Banquet Halls, East \u0026 West Salons',
        'latitude_degrees' => 43.838901,
        'longitude_degrees' => -79.080555,
        'country_iso2' => 'CA',
        'event_ids' => %w[333 222 444 555 666 777 333oh clock minx pyram skewb sq1],
        'registration_opened?' => true,
        'main_event_id' => nil,
        'number_of_bookmarks' => 68,
        'using_stripe_payments?' => false,
        'uses_qualification?' => false,
        'uses_cutoff?' => true,
        'delegates' => [
          {
            'id' => 547,
          },
        ],
        'organizers' => [
          {
            'id' => 287_748,
          },
        ],
        'tabs' => [
          {
            'id' => 29_243,
          },
        ],
        'class' => 'competition',
      }
    else
      CompetitionApi.find!(competition_id)
    end
  end
end
