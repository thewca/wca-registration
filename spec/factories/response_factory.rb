# frozen_string_literal: true

require 'factory_bot_rails'

FactoryBot.define do
  factory :permissions_response, class: Hash do
    transient do
    end

    organized_competitions { [] }

    can_attend_competitions { { 'scope' => "*" } }
    can_organize_competitions { { 'scope' => organized_competitions} }
    can_administer_competitions { { 'scope' => organized_competitions } }

    trait :admin do
      organized_competitions { "*" }
    end

    initialize_with { attributes.stringify_keys }
  end
end
