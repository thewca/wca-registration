# frozen_string_literal: true

module Mocks
  def self.permissions_mock(user_id)
    case user_id
    when '1' # Test Organizer
      {
        'can_attend_competitions' => {
          'scope' => '*',
        },
        'can_organize_competitions' => {
          'scope' => %w[CubingZANationalChampionship2023],
        },
        'can_administer_competitions' => {
          'scope' => %w[CubingZANationalChampionship2023],
        },
      }
    when '2' # Test Multi-Comp Organizer
      {
        'can_attend_competitions' => {
          'scope' => '*',
        },
        'can_organize_competitions' => {
          'scope' => %w[LazarilloOpen2023 CubingZANationalChampionship2023],
        },
        'can_administer_competitions' => {
          'scope' => %w[LazarilloOpen2023 CubingZANationalChampionship2023],
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
end
