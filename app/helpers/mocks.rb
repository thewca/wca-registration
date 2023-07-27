# frozen_string_literal: true

module Mocks
  # This needs to come from the user service*, but currently no route exists that gives this info
  def self.permissions_mock(user_id)
    case user_id
    when "1" # Test Organizer
      {
        can_attend_competitions: {
          scope: "*",
        },
        can_organize_competitions: {
          scope: %w[CubingZANationalChampionship2023],
        },
        can_administer_competitions: {
          scope: %w[CubingZANationalChampionship2023],
        },
      }
    when "2" # Test Multi-Comp Organizer
      {
        can_attend_competitions: {
          scope: "*",
        },
        can_organize_competitions: {
          scope: %w[LazarilloOpen2023 CubingZANationalChampionship2023],
        },
        can_administer_competitions: {
          scope: %w[LazarilloOpen2023 CubingZANationalChampionship2023],
        },
      }
    when "15073" # Test Admin
      {
        can_attend_competitions: {
          scope: "*",
        },
        can_organize_competitions: {
          scope: "*",
        },
        can_administer_competitions: {
          scope: "*",
        },
      }
    when "209943" # Test banned User
      {
        can_attend_competitions: {
          scope: [],
          reasons: USER_IS_BANNED,
        },
        can_organize_competitions: {
          scope: [],
        },
        can_administer_competitions: {
          scope: [],
        },
      }
    when "999999" # Test incomplete User
      {
        can_attend_competitions: {
          scope: [],
          reasons: USER_PROFILE_INCOMPLETE,
        },
        can_organize_competitions: {
          scope: [],
        },
        can_administer_competitions: {
          scope: [],
        },
      }
    else
      {
        can_attend_competitions: {
          scope: "*",
        },
        can_organize_competitions: {
          scope: [],
        },
        can_administer_competitions: {
          scope: [],
        },
      }
    end
  end
end
