# frozen_string_literal: true

module Mocks
  def self.permissions_mock(user_id)
    case user_id
    when "1" # Test Organizer
      {
        "can_attend_competitions" => {
          "scope" => "*",
        },
        "can_organize_competitions" => {
          "scope" => %w[BanjaLukaCubeDay2023],
        },
        "can_administer_competitions" => {
          "scope" => %w[BanjaLukaCubeDay2023],
        },
      }
    when "15073" # Test Admin
      {
        "can_attend_competitions" => {
          "scope" => "*",
        },
        "can_organize_competitions" => {
          "scope" => "*",
        },
        "can_administer_competitions" => {
          "scope" => "*",
        },
      }
    when "209943" # Test banned User
      {
        "can_attend_competitions" => {
          "scope" => [],
          reasons: USER_IS_BANNED,
        },
        "can_organize_competitions" => {
          "scope" => [],
        },
        "can_administer_competitions" => {
          "scope" => [],
        },
      }
    when "999999" # Test incomplete User
      {
        "can_attend_competitions" => {
          "scope" => [],
          reasons: USER_PROFILE_INCOMPLETE,
        },
        "can_organize_competitions" => {
          "scope" => [],
        },
        "can_administer_competitions" => {
          "scope" => [],
        },
      }
    else # Default value for test competitors
      {
        "can_attend_competitions" => {
          "scope" => "*",
        },
        "can_organize_competitions" => {
          "scope" => [],
        },
        "can_administer_competitions" => {
          "scope" => [],
        },
      }
    end
  end
end
