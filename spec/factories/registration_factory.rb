# frozen_string_literal: true

require 'factory_bot_rails'

FactoryBot.define do
  factory :registration do
    transient do
      events { ['333', '333mbf'] }
      comment { '' }
      guests { 0 }
      registration_status { 'incoming' }
      organizer_comment { '' }
      waiting_list_position { nil }
    end

    user_id { rand(100000..200000).to_s }
    competition_id { 'CubingZANationalChampionship2023' }
    attendee_id { "#{competition_id}-#{user_id}" }
    lanes {
      [LaneFactory.competing_lane(
        event_ids: events,
        comment: comment,
        registration_status: registration_status,
        admin_comment: organizer_comment,
        waiting_list_position: waiting_list_position,
      )]
    }
  end

  trait :admin do
    user_id { '15073' }
  end

  trait :organizer do
    user_id { '1' }
  end

  factory :organizer_registration, traits: [:organizer]
  factory :admin_registration, traits: [:admin]

  after(:create) do |registration, evaluator|
    # unless evaluator.organizer_comment.nil?
    #   attendee_id = "#{evaluator.competition_id}-#{evaluator.user_id}"
    #   registration = Registration.find(attendee_id)
    #   registration.update_competing_lane!({ organizer_comment: evaluator.organizer_comment })
    # end

    # unless evaluator.waiting_list_position.nil?
    #   puts 'adding waiting list position in factory'
    #   attendee_id = "#{evaluator.competition_id}-#{evaluator.user_id}"
    #   registration = Registration.find(attendee_id)
    #   registration.update_competing_lane!({ waiting_list_position: evaluator.waiting_list_position })
    #   puts "registration is now: #{registration.inspect}"
    #   puts "competing waiting list position: #{registration.competing_waiting_list_position}"
    # end
  end
end
