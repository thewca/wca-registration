# frozen_string_literal: true

require 'factory_bot_rails'

FactoryBot.define do
  factory :permissions_response, class: Hash do

    organized_competitions { [] }

    can_attend_competitions { { 'scope' => '*' } }
    can_organize_competitions { { 'scope' => organized_competitions } }
    can_administer_competitions { { 'scope' => organized_competitions } }

    trait :admin do
      organized_competitions { "*" }
    end

    trait :banned do
      can_attend_competitions { { 'scope' => [] } }
    end

    initialize_with { attributes.stringify_keys }
  end
end
