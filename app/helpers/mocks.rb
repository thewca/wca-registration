# frozen_string_literal: true

module Mocks
  # I created a client_intent_secret on staging using the stripe test_key
  # The issue is that you can of course only use this payment intent once
  # So in the future we need to find a better solution to this
  # (probably run a copy of the payment service if you want to test payments)
  def self.payment_ticket_mock
    %w[pi_3NaFXMGZClrCFkEy2ih4F1au_secret_HII0QlqrgZzolNM5KM4CYAmOT acct_1NYpaMGZClrCFkEy]
  end

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
