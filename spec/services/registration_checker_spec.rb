# frozen_string_literal: true

require 'rails_helper'

# TODO: Add a test where one comp has a lot of competitors and another doesnt but you can still accept, to ensure that we're checking the reg count
# for the COMPETITION, not all registrations

RSpec.shared_examples 'invalid user status updates' do |old_status, new_status|
  it "user cant change 'status' => #{old_status} to: #{new_status}" do
    registration = FactoryBot.create(:registration, registration_status: old_status)
    competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
    update_request = FactoryBot.build(:update_request, user_id: registration[:user_id], competing: { 'status' => new_status })
    stub_request(:get, UserApi.permissions_path(registration[:user_id])).to_return(status: 200, body: FactoryBot.build(:permissions_response).to_json, headers: { content_type: 'application/json' })

    expect {
      RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by'])
    }.to raise_error(RegistrationError) do |error|
      expect(error.http_status).to eq(:unauthorized)
      expect(error.error).to eq(ErrorCodes::USER_INSUFFICIENT_PERMISSIONS)
    end
  end
end

RSpec.shared_examples 'valid organizer status updates' do |old_status, new_status|
  it "organizer can change 'status' => #{old_status} to: #{new_status} before close" do
    registration = FactoryBot.create(:registration, registration_status: old_status)
    competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
    update_request = FactoryBot.build(:update_request, :organizer_for_user, user_id: registration[:user_id], competing: { 'status' => new_status })
    stub_request(:get, UserApi.permissions_path(update_request['submitted_by'])).to_return(
      status: 200,
      body: FactoryBot.build(:permissions_response, organized_competitions: [competition_info.competition_id]).to_json,
      headers: { content_type: 'application/json' },
    )

    expect { RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by']) }
      .not_to raise_error
  end

  it "site admin can change 'status' => #{old_status} to: #{new_status} before close" do
    registration = FactoryBot.create(:registration, registration_status: old_status)
    competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
    update_request = FactoryBot.build(:update_request, :site_admin, user_id: registration[:user_id], competing: { 'status' => new_status })
    stub_request(:get, UserApi.permissions_path(update_request['submitted_by'])).to_return(
      status: 200,
      body: FactoryBot.build(:permissions_response, :admin).to_json,
      headers: { content_type: 'application/json' },
    )

    expect { RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by']) }
      .not_to raise_error
  end

  it "after edit deadline/reg close, organizer can change 'status' => #{old_status} to: #{new_status}" do
    registration = FactoryBot.create(:registration, registration_status: old_status)
    competition_info = CompetitionInfo.new(FactoryBot.build(:competition, :closed))
    update_request = FactoryBot.build(:update_request, :organizer_for_user, user_id: registration[:user_id], competing: { 'status' => new_status })
    stub_request(:get, UserApi.permissions_path(update_request['submitted_by'])).to_return(
      status: 200,
      body: FactoryBot.build(:permissions_response, organized_competitions: [competition_info.competition_id]).to_json,
      headers: { content_type: 'application/json' },
    )

    expect { RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by']) }
      .not_to raise_error
  end
end

describe RegistrationChecker do
  describe '#create' do
    describe '#create_registration_allowed!' do
      it 'user must have events selected' do
        registration_request = FactoryBot.build(:registration_request, events: [])
        competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
        stub_request(:get, UserApi.permissions_path(registration_request['user_id'])).to_return(status: 200, body: FactoryBot.build(:permissions_response).to_json, headers: { content_type: 'application/json' })

        expect {
          RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:unprocessable_entity)
          expect(error.error).to eq(ErrorCodes::INVALID_EVENT_SELECTION)
        end
      end

      it 'events must be held at the competition' do
        registration_request = FactoryBot.build(:registration_request, events: ['333', '333fm'])
        competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
        stub_request(:get, UserApi.permissions_path(registration_request['user_id'])).to_return(status: 200, body: FactoryBot.build(:permissions_response).to_json, headers: { content_type: 'application/json' })

        expect {
          RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:unprocessable_entity)
          expect(error.error).to eq(ErrorCodes::INVALID_EVENT_SELECTION)
        end
      end

      it 'guests can equal the maximum allowed' do
        registration_request = FactoryBot.build(:registration_request, guests: 2)
        competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
        stub_request(:get, UserApi.permissions_path(registration_request['submitted_by'])).to_return(status: 200, body: FactoryBot.build(:permissions_response).to_json, headers: { content_type: 'application/json' })

        expect { RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request['submitted_by']) }
          .not_to raise_error
      end

      it 'guests may equal 0' do
        registration_request = FactoryBot.build(:registration_request, guests: 0)
        competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
        stub_request(:get, UserApi.permissions_path(registration_request['submitted_by'])).to_return(status: 200, body: FactoryBot.build(:permissions_response).to_json, headers: { content_type: 'application/json' })

        expect { RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request['submitted_by']) }
          .not_to raise_error
      end

      it 'guests cant exceed 0 if not allowed' do
        registration_request = FactoryBot.build(:registration_request, guests: 2)
        competition_info = CompetitionInfo.new(FactoryBot.build(:competition, guests_per_registration_limit: 0))
        stub_request(:get, UserApi.permissions_path(registration_request['submitted_by'])).to_return(status: 200, body: FactoryBot.build(:permissions_response).to_json, headers: { content_type: 'application/json' })

        expect {
          RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:unprocessable_entity)
          expect(error.error).to eq(ErrorCodes::GUEST_LIMIT_EXCEEDED)
        end
      end

      it 'guests cannot exceed the maximum allowed' do
        registration_request = FactoryBot.build(:registration_request, guests: 3)
        competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
        stub_request(:get, UserApi.permissions_path(registration_request['submitted_by'])).to_return(status: 200, body: FactoryBot.build(:permissions_response).to_json, headers: { content_type: 'application/json' })

        expect {
          RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:unprocessable_entity)
          expect(error.error).to eq(ErrorCodes::GUEST_LIMIT_EXCEEDED)
        end
      end

      it 'guests cannot be negative' do
        registration_request = FactoryBot.build(:registration_request, guests: -1)
        competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
        stub_request(:get, UserApi.permissions_path(registration_request['submitted_by'])).to_return(status: 200, body: FactoryBot.build(:permissions_response).to_json, headers: { content_type: 'application/json' })

        expect {
          RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:unprocessable_entity)
          expect(error.error).to eq(ErrorCodes::INVALID_REQUEST_DATA)
        end
      end

      it 'comment cant exceed character limit' do
        long_comment = 'comment longer than 240 characterscomment longer than 240 characterscomment longer than 240 characterscomment longer than 240 characterscomment longer than 240 characterscomment longer than 240 characterscomment longer
          than 240 characterscomment longer than 240 characters'

        registration_request = FactoryBot.build(:registration_request, :comment, raw_comment: long_comment)
        competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
        stub_request(:get, UserApi.permissions_path(registration_request['submitted_by'])).to_return(status: 200, body: FactoryBot.build(:permissions_response).to_json, headers: { content_type: 'application/json' })

        expect {
          RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:unprocessable_entity)
          expect(error.error).to eq(ErrorCodes::USER_COMMENT_TOO_LONG)
        end
      end

      it 'comment can match character limit' do
        at_character_limit = 'comment longer than 240 characterscomment longer than 240 characterscomment longer than 240 characterscomment longer than 240 characterscomment longer than 240 characterscomment longer than' \
                             '240 characterscomment longer longer than 240 12345'

        registration_request = FactoryBot.build(:registration_request, :comment, raw_comment: at_character_limit)
        competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
        stub_request(:get, UserApi.permissions_path(registration_request['submitted_by'])).to_return(status: 200, body: FactoryBot.build(:permissions_response).to_json, headers: { content_type: 'application/json' })

        expect { RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request['submitted_by']) }
          .not_to raise_error
      end

      it 'comment can be blank' do
        comment = ''
        registration_request = FactoryBot.build(:registration_request, :comment, raw_comment: comment)
        competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
        stub_request(:get, UserApi.permissions_path(registration_request['submitted_by'])).to_return(status: 200, body: FactoryBot.build(:permissions_response).to_json, headers: { content_type: 'application/json' })

        expect { RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request['submitted_by']) }
          .not_to raise_error
      end

      it 'comment must be included if required' do
        registration_request = FactoryBot.build(:registration_request)
        competition_info = CompetitionInfo.new(FactoryBot.build(:competition, force_comment_in_registration: true))
        stub_request(:get, UserApi.permissions_path(registration_request['submitted_by'])).to_return(status: 200, body: FactoryBot.build(:permissions_response).to_json, headers: { content_type: 'application/json' })

        expect {
          RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:unprocessable_entity)
          expect(error.error).to eq(ErrorCodes::REQUIRED_COMMENT_MISSING)
        end
      end

      it 'comment cant be blank if required' do
        registration_request = FactoryBot.build(:registration_request, :comment, raw_comment: '')
        competition_info = CompetitionInfo.new(FactoryBot.build(:competition, force_comment_in_registration: true))
        stub_request(:get, UserApi.permissions_path(registration_request['submitted_by'])).to_return(status: 200, body: FactoryBot.build(:permissions_response).to_json, headers: { content_type: 'application/json' })

        expect {
          RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:unprocessable_entity)
          expect(error.error).to eq(ErrorCodes::REQUIRED_COMMENT_MISSING)
        end
      end
    end

    describe '#create_registration_allowed!.user_can_create_registration!' do
      it 'user can create a registration' do
        competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
        registration_request = FactoryBot.build(:registration_request)
        stub_request(:get, UserApi.permissions_path(registration_request['submitted_by'])).to_return(status: 200, body: FactoryBot.build(:permissions_response).to_json, headers: { content_type: 'application/json' })

        expect { RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request['submitted_by']) }
          .not_to raise_error
      end

      it 'users can only register for themselves' do
        registration_request = FactoryBot.build(:registration_request, :impersonation)
        competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
        stub_request(:get, UserApi.permissions_path(registration_request['submitted_by'])).to_return(status: 200, body: FactoryBot.build(:permissions_response).to_json, headers: { content_type: 'application/json' })

        expect {
          RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:unauthorized)
          expect(error.error).to eq(ErrorCodes::USER_INSUFFICIENT_PERMISSIONS)
        end
      end

      it 'user cant register if registration is closed' do
        registration_request = FactoryBot.build(:registration_request)
        competition_info = CompetitionInfo.new(FactoryBot.build(:competition, :closed))
        stub_request(:get, UserApi.permissions_path(registration_request['user_id'])).to_return(status: 200, body: FactoryBot.build(:permissions_response).to_json, headers: { content_type: 'application/json' })

        expect {
          RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:forbidden)
          expect(error.error).to eq(ErrorCodes::REGISTRATION_CLOSED)
        end
      end

      it 'organizers can register before registration opens' do
        registration_request = FactoryBot.build(:registration_request, :organizer)
        competition_info = CompetitionInfo.new(FactoryBot.build(:competition, :closed))
        stub_request(:get, UserApi.permissions_path(registration_request['submitted_by'])).to_return(status: 200, body: FactoryBot.build(:permissions_response, organized_competitions: [competition_info.competition_id]).to_json,
                                                                                                     headers: { content_type: 'application/json' })

        expect { RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request['submitted_by']) }
          .not_to raise_error
      end

      it 'organizers cannot create registrations for users' do
        registration_request = FactoryBot.build(:registration_request, :organizer_submits)
        competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
        stub_request(:get, UserApi.permissions_path(registration_request['user_id'])).to_return(status: 200, body: FactoryBot.build(:permissions_response).to_json, headers: { content_type: 'application/json' })
        stub_request(:get, UserApi.permissions_path(registration_request['submitted_by'])).to_return(status: 200, body: FactoryBot.build(:permissions_response, organized_competitions: [competition_info.competition_id]).to_json,
                                                                                                     headers: { content_type: 'application/json' })

        expect {
          RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:unauthorized)
          expect(error.error).to eq(ErrorCodes::USER_INSUFFICIENT_PERMISSIONS)
        end
      end

      it 'can register if ban ends before competition starts', :focus do
        registration_request = FactoryBot.build(:registration_request, :unbanned_soon)
        competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
        stub_request(:get, UserApi.permissions_path(registration_request['user_id'])).to_return(
          status: 200,
          body: FactoryBot.build(:permissions_response, :unbanned_soon, ban_end_date: DateTime.parse(competition_info.start_date)-1).to_json,
          headers: { content_type: 'application/json' },
        )

        expect { RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request['submitted_by']) }
          .not_to raise_error
      end

      it 'cant register if ban ends after competition starts', :focus do
        registration_request = FactoryBot.build(:registration_request, :banned)
        competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
        stub_request(:get, UserApi.permissions_path(registration_request['user_id'])).to_return(
          status: 200, body: FactoryBot.build(:permissions_response, :banned).to_json, headers: { content_type: 'application/json' },
        )

        expect {
          RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:unauthorized)
          expect(error.error).to eq(ErrorCodes::USER_CANNOT_COMPETE)
        end
      end

      it 'user with incomplete profile cant register' do
        registration_request = FactoryBot.build(:registration_request, :incomplete)
        competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
        stub_request(:get, UserApi.permissions_path(registration_request['user_id'])).to_return(status: 200, body: FactoryBot.build(:permissions_response, :banned).to_json, headers: { content_type: 'application/json' })

        expect {
          RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:unauthorized)
          expect(error.error).to eq(ErrorCodes::USER_CANNOT_COMPETE)
        end
      end

      it 'doesnt leak data if user tries to register for a banned user' do
        registration_request = FactoryBot.build(:registration_request, :banned, :impersonation)
        competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
        stub_request(:get, UserApi.permissions_path(registration_request['submitted_by'])).to_return(status: 200, body: FactoryBot.build(:permissions_response, :banned).to_json, headers: { content_type: 'application/json' })

        expect {
          RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:unauthorized)
          expect(error.error).to eq(ErrorCodes::USER_INSUFFICIENT_PERMISSIONS)
        end
      end

      it 'doesnt leak data if organizer tries to register for a banned user' do
        registration_request = FactoryBot.build(:registration_request, :incomplete, :impersonation)
        competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
        stub_request(:get, UserApi.permissions_path(registration_request['user_id'])).to_return(status: 200, body: FactoryBot.build(:permissions_response, :banned).to_json, headers: { content_type: 'application/json' })
        stub_request(:get, UserApi.permissions_path(registration_request['submitted_by'])).to_return(status: 200, body: FactoryBot.build(:permissions_response, organized_competitions: [competition_info.competition_id]).to_json,
                                                                                                     headers: { content_type: 'application/json' })

        expect {
          RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:unauthorized)
          expect(error.error).to eq(ErrorCodes::USER_INSUFFICIENT_PERMISSIONS)
        end
      end

      it 'can register if this is the first registration in a series' do
        registration_request = FactoryBot.build(:registration_request)
        competition_info = CompetitionInfo.new(FactoryBot.build(:competition, :series))
        stub_request(:get, UserApi.permissions_path(registration_request['user_id'])).to_return(status: 200, body: FactoryBot.build(:permissions_response).to_json, headers: { content_type: 'application/json' })

        expect {
          RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request['submitted_by'])
        }.not_to raise_error
      end

      it 'cant register if already have a non-cancelled registration for another series competition' do
        registration_request = FactoryBot.build(:registration_request)
        FactoryBot.create(:registration, user_id: registration_request['user_id'], registration_status: 'accepted', competition_id: 'CubingZAWarmup2023')
        competition_info = CompetitionInfo.new(FactoryBot.build(:competition, :series))
        stub_request(:get, UserApi.permissions_path(registration_request['user_id'])).to_return(status: 200, body: FactoryBot.build(:permissions_response).to_json, headers: { content_type: 'application/json' })

        expect {
          RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.error).to eq(ErrorCodes::ALREADY_REGISTERED_IN_SERIES)
          expect(error.http_status).to eq(:forbidden)
        end
      end

      it 'can register if they have a cancelled registration for another series comp' do
        registration_request = FactoryBot.build(:registration_request)
        FactoryBot.create(:registration, user_id: registration_request['user_id'], registration_status: 'cancelled', competition_id: 'CubingZAWarmup2023')
        competition_info = CompetitionInfo.new(FactoryBot.build(:competition, :series))
        stub_request(:get, UserApi.permissions_path(registration_request['user_id'])).to_return(status: 200, body: FactoryBot.build(:permissions_response).to_json, headers: { content_type: 'application/json' })

        expect {
          RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request['submitted_by'])
        }.not_to raise_error
      end

      it 'cant re-register (register after cancelling) if they have a registration for another series comp' do
        registration = FactoryBot.create(:registration, registration_status: 'cancelled')
        FactoryBot.create(:registration, user_id: registration['user_id'], registration_status: 'accepted', competition_id: 'CubingZAWarmup2023')
        update_request = FactoryBot.build(:update_request, user_id: registration[:user_id], competing: { 'status' => 'pending' })
        competition_info = CompetitionInfo.new(FactoryBot.build(:competition, :series))
        stub_request(:get, UserApi.permissions_path(update_request['user_id'])).to_return(status: 200, body: FactoryBot.build(:permissions_response).to_json, headers: { content_type: 'application/json' })

        expect {
          RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.error).to eq(ErrorCodes::ALREADY_REGISTERED_IN_SERIES)
          expect(error.http_status).to eq(:forbidden)
        end
      end
    end

    describe '#create_registration_allowed!.validate_create_events!' do
      it 'user must have events selected' do
        registration_request = FactoryBot.build(:registration_request, events: [])
        competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
        stub_request(:get, UserApi.permissions_path(registration_request['user_id'])).to_return(status: 200, body: FactoryBot.build(:permissions_response).to_json, headers: { content_type: 'application/json' })

        expect {
          RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:unprocessable_entity)
          expect(error.error).to eq(ErrorCodes::INVALID_EVENT_SELECTION)
        end
      end

      it 'events must be held at the competition' do
        registration_request = FactoryBot.build(:registration_request, events: ['333', '333fm'])
        competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
        stub_request(:get, UserApi.permissions_path(registration_request['user_id'])).to_return(status: 200, body: FactoryBot.build(:permissions_response).to_json, headers: { content_type: 'application/json' })

        expect {
          RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:unprocessable_entity)
          expect(error.error).to eq(ErrorCodes::INVALID_EVENT_SELECTION)
        end
      end

      it 'competitor can register up to the events_per_registration_limit limit' do
        registration_request = FactoryBot.build(:registration_request, events: ['333', '222', '444', '555', '666'])
        competition_info = CompetitionInfo.new(FactoryBot.build(:competition, events_per_registration_limit: 5))
        stub_request(:get, UserApi.permissions_path(registration_request['user_id'])).to_return(status: 200, body: FactoryBot.build(:permissions_response).to_json, headers: { content_type: 'application/json' })

        expect { RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request['submitted_by']) }
          .not_to raise_error
      end

      it 'competitor cant register more events than the events_per_registration_limit' do
        registration_request = FactoryBot.build(:registration_request, events: ['333', '222', '444', '555', '666', '777'])
        competition_info = CompetitionInfo.new(FactoryBot.build(:competition, events_per_registration_limit: 5))
        stub_request(:get, UserApi.permissions_path(registration_request['user_id'])).to_return(status: 200, body: FactoryBot.build(:permissions_response).to_json, headers: { content_type: 'application/json' })

        expect {
          RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:forbidden)
          expect(error.error).to eq(ErrorCodes::INVALID_EVENT_SELECTION)
        end
      end

      it 'organizer cant register more events than the events_per_registration_limit' do
        registration_request = FactoryBot.build(:registration_request, :organizer, events: ['333', '222', '444', '555', '666', '777'])
        competition_info = CompetitionInfo.new(FactoryBot.build(:competition, events_per_registration_limit: 5))
        stub_request(:get, UserApi.permissions_path(registration_request['user_id'])).to_return(status: 200, body: FactoryBot.build(:permissions_response, organized_competitions: [competition_info.competition_id]).to_json,
                                                                                                headers: { content_type: 'application/json' })
        expect {
          RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:forbidden)
          expect(error.error).to eq(ErrorCodes::INVALID_EVENT_SELECTION)
        end
      end
    end
  end

  describe '#update', :tag do
    before do
      @registration = FactoryBot.create(:registration)
      @competition_info = CompetitionInfo.new(FactoryBot.build(:competition))

      # Stub admin permissions
      stub_request(:get, UserApi.permissions_path(1306)).to_return(
        status: 200,
        body: FactoryBot.build(:permissions_response, organized_competitions: [@competition_info.competition_id]).to_json,
        headers: { content_type: 'application/json' },
      )

      # Stub alternate user permissions
      stub_request(:get, UserApi.permissions_path(188000)).to_return(
        status: 200,
        body: FactoryBot.build(:permissions_response).to_json,
        headers: { content_type: 'application/json' },
      )
    end

    describe '#update_registration_allowed!.user_can_modify_registration!' do
      it 'raises error if registration doesnt exist' do
        update_request = FactoryBot.build(:update_request, user_id: (@registration[:user_id] -1))

        expect {
          RegistrationChecker.update_registration_allowed!(update_request, @competition_info, update_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.error).to eq(ErrorCodes::REGISTRATION_NOT_FOUND)
          expect(error.http_status).to eq(:not_found)
        end
      end

      it 'user can change their registration' do
        update_request = FactoryBot.build(:update_request, user_id: @registration[:user_id])

        expect { RegistrationChecker.update_registration_allowed!(update_request, @competition_info, update_request['submitted_by']) }
          .not_to raise_error
      end

      it 'User A cant change User Bs registration' do
        update_request = FactoryBot.build(:update_request, :for_another_user, user_id: @registration[:user_id])

        stub_request(:get, UserApi.permissions_path(update_request['submitted_by'])).to_return(status: 200, body: FactoryBot.build(:permissions_response).to_json, headers: { content_type: 'application/json' })

        expect {
          RegistrationChecker.update_registration_allowed!(update_request, @competition_info, update_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:unauthorized)
          expect(error.error).to eq(ErrorCodes::USER_INSUFFICIENT_PERMISSIONS)
        end
      end

      it 'user cant update registration if registration edits arent allowed' do
        override_competition_info = CompetitionInfo.new(FactoryBot.build(:competition, allow_registration_edits: false))
        update_request = FactoryBot.build(:update_request, user_id: @registration[:user_id])

        expect {
          RegistrationChecker.update_registration_allowed!(update_request, override_competition_info, update_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:forbidden)
          expect(error.error).to eq(ErrorCodes::USER_EDITS_NOT_ALLOWED)
        end
      end

      it 'user cant change events after event change deadline' do
        override_competition_info = CompetitionInfo.new(FactoryBot.build(:competition, :event_change_deadline_passed))
        update_request = FactoryBot.build(:update_request, user_id: @registration[:user_id], competing: { 'event_ids' => ['333', '444', '555'] })

        expect {
          RegistrationChecker.update_registration_allowed!(update_request, override_competition_info, update_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:forbidden)
          expect(error.error).to eq(ErrorCodes::USER_EDITS_NOT_ALLOWED)
        end
      end

      it 'organizer can change user registration' do
        update_request = FactoryBot.build(:update_request, :organizer_for_user, user_id: @registration[:user_id])

        expect { RegistrationChecker.update_registration_allowed!(update_request, @competition_info, update_request['submitted_by']) }
          .not_to raise_error
      end

      it 'organizer can change registration after change deadline' do
        update_request = FactoryBot.build(:update_request, :organizer_for_user, user_id: @registration[:user_id], competing: { 'comment' => 'this is a new comment' })

        expect { RegistrationChecker.update_registration_allowed!(update_request, @competition_info, update_request['submitted_by']) }
          .not_to raise_error
      end
    end

    describe '#update_registration_allowed!.validate_comment!' do
      it 'user can change comment' do
        update_request = FactoryBot.build(:update_request, user_id: @registration[:user_id], competing: { 'comment' => 'new comment' })

        expect { RegistrationChecker.update_registration_allowed!(update_request, @competition_info, update_request['submitted_by']) }
          .not_to raise_error
      end

      it 'user cant exceed comment length' do
        long_comment = 'comment longer than 240 characterscomment longer than 240 characterscomment longer than 240 characterscomment longer than 240 characterscomment longer than 240 characterscomment longer than 240 characterscomment longer
          than 240 characterscomment longer than 240 characters'

        update_request = FactoryBot.build(:update_request, user_id: @registration[:user_id], competing: { 'comment' => long_comment })

        expect {
          RegistrationChecker.update_registration_allowed!(update_request, @competition_info, update_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:unprocessable_entity)
          expect(error.error).to eq(ErrorCodes::USER_COMMENT_TOO_LONG)
        end
      end

      it 'user can match comment length' do
        at_character_limit = 'comment longer than 240 characterscomment longer than 240 characterscomment longer than 240 characterscomment longer than 240 characterscomment longer than 240 characterscomment longer than' \
                             '240 characterscomment longer longer than 240 12345'

        update_request = FactoryBot.build(:update_request, user_id: @registration[:user_id], competing: { 'comment' => at_character_limit })

        expect { RegistrationChecker.update_registration_allowed!(update_request, @competition_info, update_request['submitted_by']) }
          .not_to raise_error
      end

      it 'comment can be blank' do
        update_request = FactoryBot.build(:update_request, user_id: @registration[:user_id], competing: { 'comment' => '' })

        expect { RegistrationChecker.update_registration_allowed!(update_request, @competition_info, update_request['submitted_by']) }
          .not_to raise_error
      end

      it 'comment cant be blank if required' do
        override_competition_info = CompetitionInfo.new(FactoryBot.build(:competition, force_comment_in_registration: true))
        update_request = FactoryBot.build(:update_request, user_id: @registration[:user_id], competing: { 'comment' => '' })

        expect {
          RegistrationChecker.update_registration_allowed!(update_request, override_competition_info, update_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:unprocessable_entity)
          expect(error.error).to eq(ErrorCodes::REQUIRED_COMMENT_MISSING)
        end
      end

      it 'mandatory comment: updates without comments are allowed as long as a comment already exists in the registration' do
        override_registration = FactoryBot.create(:registration, user_id: 188000, comment: 'this is a test comment')
        override_competition_info = CompetitionInfo.new(FactoryBot.build(:competition, force_comment_in_registration: true))
        update_request = FactoryBot.build(:update_request, user_id: override_registration[:user_id], competing: { 'status' => 'cancelled' })

        stub_request(:get, UserApi.permissions_path(update_request['submitted_by'])).to_return(
          status: 200,
          body: FactoryBot.build(:permissions_response).to_json,
          headers: { content_type: 'application/json' },
        )

        expect { RegistrationChecker.update_registration_allowed!(update_request, override_competition_info, update_request['submitted_by']) }
          .not_to raise_error
      end

      it 'oranizer can change registration state when comment is mandatory' do
        override_registration = FactoryBot.create(:registration, user_id: 188000, comment: 'this is a test comment')
        override_competition_info = CompetitionInfo.new(FactoryBot.build(:competition, force_comment_in_registration: true))
        update_request = FactoryBot.build(:update_request, :organizer_for_user, user_id: override_registration[:user_id], competing: { 'status' => 'accepted' })

        expect { RegistrationChecker.update_registration_allowed!(update_request, override_competition_info, update_request['submitted_by']) }
          .not_to raise_error
      end

      it 'organizer can change user comment' do
        registration = FactoryBot.create(:registration, comment: 'original comment')
        update_request = FactoryBot.build(:update_request, :organizer_for_user, user_id: registration[:user_id], competing: { 'comment' => '' })

        expect { RegistrationChecker.update_registration_allowed!(update_request, @competition_info, update_request['submitted_by']) }
          .not_to raise_error
      end

      it 'organizer cant exceed comment length' do
        long_comment = 'comment longer than 240 characterscomment longer than 240 characterscomment longer than 240 characterscomment longer than 240 characterscomment longer than 240 characterscomment longer than 240 characterscomment longer
          than 240 characterscomment longer than 240 characters'

        update_request = FactoryBot.build(:update_request, :organizer_for_user, user_id: @registration[:user_id], competing: { 'comment' => long_comment })

        expect {
          RegistrationChecker.update_registration_allowed!(update_request, @competition_info, update_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:unprocessable_entity)
          expect(error.error).to eq(ErrorCodes::USER_COMMENT_TOO_LONG)
        end
      end

      it 'user cant change comment after edit events deadline' do
        override_competition_info = CompetitionInfo.new(FactoryBot.build(:competition, :event_change_deadline_passed))
        update_request = FactoryBot.build(:update_request, user_id: @registration[:user_id], competing: { 'comment' => 'this is a new comment' })

        expect {
          RegistrationChecker.update_registration_allowed!(update_request, override_competition_info, update_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:forbidden)
          expect(error.error).to eq(ErrorCodes::USER_EDITS_NOT_ALLOWED)
        end
      end
    end

    describe '#update_registration_allowed!.validate_organizer_fields!' do
      it 'organizer can add organizer_comment' do
        update_request = FactoryBot.build(
          :update_request,
          :organizer_for_user,
          user_id: @registration[:user_id],
          competing: { 'organizer_comment' => 'this is an admin comment' },
        )

        expect { RegistrationChecker.update_registration_allowed!(update_request, @competition_info, update_request['submitted_by']) }
          .not_to raise_error
      end

      it 'organizer can change organizer_comment' do
        override_registration = FactoryBot.create(:registration, user_id: 188000, organizer_comment: 'old admin comment')
        update_request = FactoryBot.build(:update_request, :organizer_for_user, user_id: override_registration[:user_id], competing: { 'organizer_comment' => 'new admin comment' })

        expect { RegistrationChecker.update_registration_allowed!(update_request, @competition_info, update_request['submitted_by']) }
          .not_to raise_error
      end

      it 'user cant submit an organizer comment' do
        update_request = FactoryBot.build(:update_request, user_id: @registration[:user_id], competing: { 'organizer_comment' => 'new admin comment' })

        expect {
          RegistrationChecker.update_registration_allowed!(update_request, @competition_info, update_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:unauthorized)
          expect(error.error).to eq(ErrorCodes::USER_INSUFFICIENT_PERMISSIONS)
        end
      end

      it 'user cant submit waiting_list_position' do
        update_request = FactoryBot.build(:update_request, user_id: @registration[:user_id], competing: { 'waiting_list_position' => '1' })

        expect {
          RegistrationChecker.update_registration_allowed!(update_request, @competition_info, update_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:unauthorized)
          expect(error.error).to eq(ErrorCodes::USER_INSUFFICIENT_PERMISSIONS)
        end
      end
    end

    describe '#update_registration_allowed!.validate_organizer_comment!' do
      it 'organizer comment cant exceed 240 characters' do
        long_comment = 'comment longer than 240 characterscomment longer than 240 characterscomment longer than 240 characterscomment longer than 240 characterscomment longer than 240 characterscomment longer than 240 characterscomment longer
        than 240 characterscomment longer than 240 characters'

        update_request = FactoryBot.build(:update_request, :organizer_for_user, user_id: @registration[:user_id], competing: { 'organizer_comment' => long_comment })

        expect {
          RegistrationChecker.update_registration_allowed!(update_request, @competition_info, update_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:unprocessable_entity)
          expect(error.error).to eq(ErrorCodes::USER_COMMENT_TOO_LONG)
        end
      end

      it 'organizer comment can match 240 characters' do
        at_character_limit = 'comment longer than 240 characterscomment longer than 240 characterscomment longer than 240 characterscomment longer than 240 characterscomment longer than 240 characterscomment longer than' \
                             '240 characterscomment longer longer than 240 12345'

        update_request = FactoryBot.build(:update_request, :organizer_for_user, user_id: @registration[:user_id], competing: { 'organizer_comment' => at_character_limit })

        expect { RegistrationChecker.update_registration_allowed!(update_request, @competition_info, update_request['submitted_by']) }
          .not_to raise_error
      end
    end

    describe '#update_registration_allowed!.validate_guests!' do
      it 'user can change number of guests' do
        update_request = FactoryBot.build(:update_request, user_id: @registration[:user_id], guests: 2)

        expect { RegistrationChecker.update_registration_allowed!(update_request, @competition_info, update_request['submitted_by']) }
          .not_to raise_error
      end

      it 'guests cant exceed guest limit' do
        update_request = FactoryBot.build(:update_request, user_id: @registration[:user_id], guests: 3)

        expect {
          RegistrationChecker.update_registration_allowed!(update_request, @competition_info, update_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:unprocessable_entity)
          expect(error.error).to eq(ErrorCodes::GUEST_LIMIT_EXCEEDED)
        end
      end

      it 'guests can match guest limit' do
        update_request = FactoryBot.build(:update_request, user_id: @registration[:user_id], guests: 2)

        expect { RegistrationChecker.update_registration_allowed!(update_request, @competition_info, update_request['submitted_by']) }
          .not_to raise_error
      end

      it 'guests can be zero' do
        update_request = FactoryBot.build(:update_request, user_id: @registration[:user_id], guests: 0)

        expect { RegistrationChecker.update_registration_allowed!(update_request, @competition_info, update_request['submitted_by']) }
          .not_to raise_error
      end

      it 'guests cant be negative' do
        update_request = FactoryBot.build(:update_request, user_id: @registration[:user_id], guests: -1)

        expect {
          RegistrationChecker.update_registration_allowed!(update_request, @competition_info, update_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:unprocessable_entity)
          expect(error.error).to eq(ErrorCodes::INVALID_REQUEST_DATA)
        end
      end

      it 'guests have no limit if guest limit not set' do
        override_competition_info = CompetitionInfo.new(FactoryBot.build(:competition, :no_guest_limit))
        update_request = FactoryBot.build(:update_request, user_id: @registration[:user_id], guests: 99)

        expect { RegistrationChecker.update_registration_allowed!(update_request, override_competition_info, update_request['submitted_by']) }
          .not_to raise_error
      end

      it 'organizer can change number of guests' do
        update_request = FactoryBot.build(:update_request, :organizer_for_user, user_id: @registration[:user_id], guests: 2)

        expect { RegistrationChecker.update_registration_allowed!(update_request, @competition_info, update_request['submitted_by']) }
          .not_to raise_error
      end

      it 'User A cant change User Bs guests' do
        update_request = FactoryBot.build(:update_request, :for_another_user, user_id: @registration[:user_id], guests: 2)

        stub_request(:get, UserApi.permissions_path(update_request['submitted_by'])).to_return(
          status: 200,
          body: FactoryBot.build(:permissions_response).to_json,
          headers: { content_type: 'application/json' },
        )

        expect {
          RegistrationChecker.update_registration_allowed!(update_request, @competition_info, update_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:unauthorized)
          expect(error.error).to eq(ErrorCodes::USER_INSUFFICIENT_PERMISSIONS)
        end
      end

      it 'user cant change guests after registration change deadline' do
        override_competition_info = CompetitionInfo.new(FactoryBot.build(:competition, event_change_deadline_date: '2022-06-14T00:00:00.000Z'))
        update_request = FactoryBot.build(:update_request, user_id: @registration[:user_id], guests: 2)

        expect {
          RegistrationChecker.update_registration_allowed!(update_request, override_competition_info, update_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:forbidden)
          expect(error.error).to eq(ErrorCodes::USER_EDITS_NOT_ALLOWED)
        end
      end

      it 'organizer can change guests after registration change deadline' do
        override_competition_info = CompetitionInfo.new(FactoryBot.build(:competition, event_change_deadline_date: '2022-06-14T00:00:00.000Z'))
        update_request = FactoryBot.build(:update_request, :organizer_for_user, user_id: @registration[:user_id], guests: 2)

        expect { RegistrationChecker.update_registration_allowed!(update_request, override_competition_info, update_request['submitted_by']) }
          .not_to raise_error
      end
    end

    describe '#update_registration_allowed!.validate_update_status!' do
      it 'user cant submit an invalid status' do
        override_registration = FactoryBot.create(:registration, user_id: 188000, registration_status: 'waiting_list')
        update_request = FactoryBot.build(:update_request, user_id: override_registration[:user_id], competing: { 'status' => 'random_status' })

        expect {
          RegistrationChecker.update_registration_allowed!(update_request, @competition_info, update_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:unprocessable_entity)
          expect(error.error).to eq(ErrorCodes::INVALID_REQUEST_DATA)
        end
      end

      it 'organizer cant submit an invalid status' do
        override_registration = FactoryBot.create(:registration, user_id: 188000, registration_status: 'waiting_list')
        update_request = FactoryBot.build(:update_request, :organizer_as_user, user_id: override_registration[:user_id], competing: { 'status' => 'random_status' })

        expect {
          RegistrationChecker.update_registration_allowed!(update_request, @competition_info, update_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:unprocessable_entity)
          expect(error.error).to eq(ErrorCodes::INVALID_REQUEST_DATA)
        end
      end

      it 'organizer cant accept a user when registration list is full' do
        FactoryBot.create_list(:registration, 3, registration_status: 'accepted')
        override_registration = FactoryBot.create(:registration, user_id: 188000, registration_status: 'waiting_list')
        override_competition_info = CompetitionInfo.new(FactoryBot.build(:competition, competitor_limit: 3))
        update_request = FactoryBot.build(:update_request, :organizer_for_user, user_id: override_registration[:user_id], competing: { 'status' => 'accepted' })

        expect {
          RegistrationChecker.update_registration_allowed!(update_request, override_competition_info, update_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.error).to eq(ErrorCodes::COMPETITOR_LIMIT_REACHED)
          expect(error.http_status).to eq(:forbidden)
        end
      end

      it 'organizer can accept registrations up to the limit' do
        FactoryBot.create_list(:registration, 2, registration_status: 'accepted')
        registration = FactoryBot.create(:registration, registration_status: 'waiting_list')
        competition_info = CompetitionInfo.new(FactoryBot.build(:competition, competitor_limit: 3))
        update_request = FactoryBot.build(:update_request, :organizer_for_user, user_id: registration[:user_id], competing: { 'status' => 'accepted' })

        expect { RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by']) }
          .not_to raise_error
      end

      it 'user can change state to cancelled' do
        override_registration = FactoryBot.create(:registration, user_id: 188000, registration_status: 'waiting_list')
        update_request = FactoryBot.build(:update_request, user_id: override_registration[:user_id], competing: { 'status' => 'cancelled' })

        expect { RegistrationChecker.update_registration_allowed!(update_request, @competition_info, update_request['submitted_by']) }
          .not_to raise_error
      end

      it 'user cant change events when cancelling' do
        override_registration = FactoryBot.create(:registration, user_id: 188000, registration_status: 'waiting_list')
        update_request = FactoryBot.build(
          :update_request, user_id: override_registration[:user_id], competing: { 'status' => 'cancelled', 'event_ids' => ['333'] }
        )

        expect {
          RegistrationChecker.update_registration_allowed!(update_request, @competition_info, update_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:unprocessable_entity)
          expect(error.error).to eq(ErrorCodes::INVALID_REQUEST_DATA)
        end
      end

      it 'user can change state from cancelled to pending' do
        override_registration = FactoryBot.create(:registration, user_id: 188000, registration_status: 'cancelled')
        update_request = FactoryBot.build(:update_request, user_id: override_registration[:user_id], competing: { 'status' => 'pending' })

        expect { RegistrationChecker.update_registration_allowed!(update_request, @competition_info, update_request['submitted_by']) }
          .not_to raise_error
      end

      [
        { old_status: 'pending', new_status: 'accepted' },
        { old_status: 'pending', new_status: 'waiting_list' },
        { old_status: 'pending', new_status: 'pending' },
        { old_status: 'waiting_list', new_status: 'pending' },
        { old_status: 'waiting_list', new_status: 'waiting_list' },
        { old_status: 'waiting_list', new_status: 'accepted' },
        { old_status: 'accepted', new_status: 'pending' },
        { old_status: 'accepted', new_status: 'waiting_list' },
        { old_status: 'accepted', new_status: 'accepted' },
        { old_status: 'cancelled', new_status: 'accepted' },
        { old_status: 'cancelled', new_status: 'waiting_list' },
      ].each do |params|
        it_behaves_like 'invalid user status updates', params[:old_status], params[:new_status]
      end

      it 'user cant cancel accepted registration if competition requires organizers to cancel registration' do
        override_registration = FactoryBot.create(:registration, user_id: 188000, registration_status: 'accepted')
        override_competition_info = CompetitionInfo.new(FactoryBot.build(:competition, allow_registration_self_delete_after_acceptance: false))
        update_request = FactoryBot.build(:update_request, user_id: override_registration[:user_id], competing: { 'status' => 'cancelled' })

        expect {
          RegistrationChecker.update_registration_allowed!(update_request, override_competition_info, update_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:unauthorized)
          expect(error.error).to eq(ErrorCodes::ORGANIZER_MUST_CANCEL_REGISTRATION)
        end
      end

      it 'user can cancel non-accepted registration if competition requires organizers to cancel registration' do
        override_registration = FactoryBot.create(:registration, registration_status: 'waiting_list')
        override_competition_info = CompetitionInfo.new(FactoryBot.build(:competition, allow_registration_self_delete_after_acceptance: false))
        update_request = FactoryBot.build(:update_request, user_id: override_registration[:user_id], competing: { 'status' => 'cancelled' })

        stub_request(:get, UserApi.permissions_path(update_request['submitted_by'])).to_return(
          status: 200,
          body: FactoryBot.build(:permissions_response).to_json,
          headers: { content_type: 'application/json' },
        )

        expect { RegistrationChecker.update_registration_allowed!(update_request, override_competition_info, update_request['submitted_by']) }
          .not_to raise_error
      end

      it 'user cant cancel registration after registration ends' do
        override_competition_info = CompetitionInfo.new(FactoryBot.build(:competition, :closed))
        update_request = FactoryBot.build(:update_request, user_id: @registration[:user_id], competing: { 'status' => 'cancelled' })

        expect {
          RegistrationChecker.update_registration_allowed!(update_request, override_competition_info, update_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:forbidden)
          expect(error.error).to eq(ErrorCodes::USER_EDITS_NOT_ALLOWED)
        end
      end

      [
        { old_status: 'pending', new_status: 'accepted' },
        { old_status: 'pending', new_status: 'waiting_list' },
        { old_status: 'pending', new_status: 'cancelled' },
        { old_status: 'pending', new_status: 'pending' },
        { old_status: 'waiting_list', new_status: 'pending' },
        { old_status: 'waiting_list', new_status: 'cancelled' },
        { old_status: 'waiting_list', new_status: 'waiting_list' },
        { old_status: 'waiting_list', new_status: 'accepted' },
        { old_status: 'accepted', new_status: 'pending' },
        { old_status: 'accepted', new_status: 'cancelled' },
        { old_status: 'accepted', new_status: 'waiting_list' },
        { old_status: 'accepted', new_status: 'accepted' },
        { old_status: 'cancelled', new_status: 'accepted' },
        { old_status: 'cancelled', new_status: 'pending' },
        { old_status: 'cancelled', new_status: 'waiting_list' },
        { old_status: 'cancelled', new_status: 'cancelled' },
      ].each do |params|
        it_behaves_like 'valid organizer status updates', params[:old_status], params[:new_status]
      end

      it 'organizer can cancel registration after registration ends' do
        override_competition_info = CompetitionInfo.new(FactoryBot.build(:competition, :closed))
        update_request = FactoryBot.build(:update_request, :organizer_for_user, user_id: @registration[:user_id], competing: { 'status' => 'cancelled' })

        expect { RegistrationChecker.update_registration_allowed!(update_request, override_competition_info, update_request['submitted_by']) }
          .not_to raise_error
      end
    end

    describe '#update_registration_allowed!.validate_update_events!' do
      it 'user can add events' do
        update_request = FactoryBot.build(
          :update_request, user_id: @registration[:user_id], competing: { 'event_ids' => ['333', '444', '555', '333mbf'] }
        )

        expect { RegistrationChecker.update_registration_allowed!(update_request, @competition_info, update_request['submitted_by']) }
          .not_to raise_error
      end

      it 'user can remove events' do
        update_request = FactoryBot.build(
          :update_request, user_id: @registration[:user_id], competing: { 'event_ids' => ['333'] }
        )

        expect { RegistrationChecker.update_registration_allowed!(update_request, @competition_info, update_request['submitted_by']) }
          .not_to raise_error
      end

      it 'user can remove all old events and register for new ones' do
        update_request = FactoryBot.build(
          :update_request, user_id: @registration[:user_id], competing: { 'event_ids' => ['777', '333bf'] }
        )

        expect { RegistrationChecker.update_registration_allowed!(update_request, @competition_info, update_request['submitted_by']) }
          .not_to raise_error
      end

      it 'events list cant be blank' do
        update_request = FactoryBot.build(:update_request, user_id: @registration[:user_id], competing: { 'event_ids' => [] })

        expect {
          RegistrationChecker.update_registration_allowed!(update_request, @competition_info, update_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:unprocessable_entity)
          expect(error.error).to eq(ErrorCodes::INVALID_EVENT_SELECTION)
        end
      end

      it 'events must be held at the competition' do
        update_request = FactoryBot.build(:update_request, user_id: @registration[:user_id], competing: { 'event_ids' => ['333fm', '333'] })

        expect {
          RegistrationChecker.update_registration_allowed!(update_request, @competition_info, update_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:unprocessable_entity)
          expect(error.error).to eq(ErrorCodes::INVALID_EVENT_SELECTION)
        end
      end

      it 'events must exist' do
        update_request = FactoryBot.build(:update_request, user_id: @registration[:user_id], competing: { 'event_ids' => ['888', '333'] })

        expect {
          RegistrationChecker.update_registration_allowed!(update_request, @competition_info, update_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:unprocessable_entity)
          expect(error.error).to eq(ErrorCodes::INVALID_EVENT_SELECTION)
        end
      end

      it 'organizer can change a users events' do
        update_request = FactoryBot.build(
          :update_request, :organizer_for_user, user_id: @registration[:user_id], competing: { 'event_ids' => ['333', '666'] }
        )

        expect { RegistrationChecker.update_registration_allowed!(update_request, @competition_info, update_request['submitted_by']) }
          .not_to raise_error
      end

      it 'organizer cant change users events to events not held at competition' do
        update_request = FactoryBot.build(
          :update_request, :organizer_for_user, user_id: @registration[:user_id], competing: { 'event_ids' => ['333fm', '333'] }
        )

        expect {
          RegistrationChecker.update_registration_allowed!(update_request, @competition_info, update_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:unprocessable_entity)
          expect(error.error).to eq(ErrorCodes::INVALID_EVENT_SELECTION)
        end
      end

      it 'competitor can update registration with events up to the events_per_registration_limit limit' do
        override_competition_info = CompetitionInfo.new(FactoryBot.build(:competition, events_per_registration_limit: 5))
        update_request = FactoryBot.build(:update_request, user_id: @registration[:user_id], competing: { 'event_ids' => ['333', '222', '444', '555', '666'] })

        expect { RegistrationChecker.update_registration_allowed!(update_request, override_competition_info, update_request['submitted_by']) }
          .not_to raise_error
      end

      it 'competitor cant update registration to more events than the events_per_registration_limit' do
        update_request = FactoryBot.build(:update_request, user_id: @registration[:user_id], competing: { 'event_ids' => ['333', '222', '444', '555', '666', '777'] })
        override_competition_info = CompetitionInfo.new(FactoryBot.build(:competition, events_per_registration_limit: 5))

        expect {
          RegistrationChecker.update_registration_allowed!(update_request, override_competition_info, update_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:forbidden)
          expect(error.error).to eq(ErrorCodes::INVALID_EVENT_SELECTION)
        end
      end

      it 'organizer cant update their registration with more events than the events_per_registration_limit' do
        update_request = FactoryBot.build(
          :update_request, user_id: @registration[:user_id], competing: { 'event_ids' => ['333', '222', '444', '555', '666', '777'] }
        )
        override_competition_info = CompetitionInfo.new(FactoryBot.build(:competition, events_per_registration_limit: 5))

        expect {
          RegistrationChecker.update_registration_allowed!(update_request, override_competition_info, update_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:forbidden)
          expect(error.error).to eq(ErrorCodes::INVALID_EVENT_SELECTION)
        end
      end
    end

    describe '#update_registration_allowed!.validate_waiting_list_position!' do
      it 'must be an integer, not string' do
        update_request = FactoryBot.build(:update_request, :organizer_for_user, user_id: @registration[:user_id], competing: { 'waiting_list_position' => 'b' })

        expect {
          RegistrationChecker.update_registration_allowed!(update_request, @competition_info, update_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:unprocessable_entity)
          expect(error.error).to eq(ErrorCodes::INVALID_WAITING_LIST_POSITION)
        end
      end

      it 'can be an integer given as a string' do
        update_request = FactoryBot.build(:update_request, :organizer_for_user, user_id: @registration[:user_id], competing: { 'waiting_list_position' => '1' })

        expect {
          RegistrationChecker.update_registration_allowed!(update_request, @competition_info, update_request['submitted_by'])
        }.not_to raise_error
      end

      it 'must be an integer, not float' do
        update_request = FactoryBot.build(:update_request, :organizer_for_user, user_id: @registration[:user_id], competing: { 'waiting_list_position' => 2.0 })

        expect {
          RegistrationChecker.update_registration_allowed!(update_request, @competition_info, update_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:unprocessable_entity)
          expect(error.error).to eq(ErrorCodes::INVALID_WAITING_LIST_POSITION)
        end
      end

      it 'organizer cant accept anyone except the min position on the waiting list' do
        FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => '1')
        override_registration = FactoryBot.create(:registration, user_id: 188000, registration_status: 'waiting_list', 'waiting_list_position' => '2')
        update_request = FactoryBot.build(:update_request, :organizer_for_user, user_id: override_registration[:user_id], competing: { 'status' => 'accepted' })

        expect {
          RegistrationChecker.update_registration_allowed!(update_request, @competition_info, update_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:forbidden)
          expect(error.error).to eq(ErrorCodes::MUST_ACCEPT_WAITING_LIST_LEADER)
        end
      end

      it 'cannot move to less than current min position' do
        override_registration = FactoryBot.create(:registration, user_id: 188000, registration_status: 'waiting_list', 'waiting_list_position' => 1)
        FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 2)
        FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 3)
        FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 4)
        FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 5)

        update_request = FactoryBot.build(:update_request, :organizer_for_user, user_id: override_registration[:user_id], competing: { 'waiting_list_position' => '10' })

        expect {
          RegistrationChecker.update_registration_allowed!(update_request, @competition_info, update_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:forbidden)
          expect(error.error).to eq(ErrorCodes::INVALID_WAITING_LIST_POSITION)
        end
      end

      it 'cannot move to greater than current max position' do
        override_registration = FactoryBot.create(:registration, user_id: 188000, registration_status: 'waiting_list', 'waiting_list_position' => 6)
        FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 2)
        FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 3)
        FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 4)
        FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 5)

        update_request = FactoryBot.build(:update_request, :organizer_for_user, user_id: override_registration[:user_id], competing: { 'waiting_list_position' => '1' })

        expect {
          RegistrationChecker.update_registration_allowed!(update_request, @competition_info, update_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.http_status).to eq(:forbidden)
          expect(error.error).to eq(ErrorCodes::INVALID_WAITING_LIST_POSITION)
        end
      end
    end
  end

  describe '#bulk_update' do
    describe '#bulk_update_allowed!' do
      it 'only organizers can submit bulk updates' do
        registration = FactoryBot.create(:registration)
        failed_update = FactoryBot.build(:update_request, user_id: registration[:user_id])
        competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
        bulk_update_request = FactoryBot.build(:bulk_update_request, requests: [failed_update], submitted_by: registration[:user_id])

        expect {
          RegistrationChecker.bulk_update_allowed!(bulk_update_request, competition_info, bulk_update_request['submitted_by'])
        }.to raise_error(BulkUpdateError) do |error|
          expect(error.errors).to eq([ErrorCodes::USER_INSUFFICIENT_PERMISSIONS])
          expect(error.http_status).to eq(:unauthorized)
        end
      end

      it 'doesnt raise an error if all checks pass - single update' do
        registration = FactoryBot.create(:registration)
        competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
        bulk_update_request = FactoryBot.build(:bulk_update_request, user_ids: [registration[:user_id]])

        expect {
          RegistrationChecker.bulk_update_allowed!(bulk_update_request, competition_info, bulk_update_request['submitted_by'])
        }.not_to raise_error
      end

      it 'doesnt raise an error if all checks pass - 3 updates' do
        registration = FactoryBot.create(:registration)
        registration2 = FactoryBot.create(:registration)
        registration3 = FactoryBot.create(:registration)
        registrations = [registration[:user_id], registration2[:user_id], registration3[:user_id]]
        competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
        bulk_update_request = FactoryBot.build(:bulk_update_request, user_ids: registrations)

        expect {
          RegistrationChecker.bulk_update_allowed!(bulk_update_request, competition_info, bulk_update_request['submitted_by'])
        }.not_to raise_error
      end

      it 'returns an array user_ids:error codes - 1 failure' do
        registration = FactoryBot.create(:registration)
        failed_update = FactoryBot.build(:update_request, user_id: registration[:user_id], competing: { 'event_ids' => [] })
        competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
        bulk_update_request = FactoryBot.build(:bulk_update_request, requests: [failed_update])

        expect {
          RegistrationChecker.bulk_update_allowed!(bulk_update_request, competition_info, bulk_update_request['submitted_by'])
        }.to raise_error(BulkUpdateError) do |error|
          expect(error.errors).to eq({ registration[:user_id] => ErrorCodes::INVALID_EVENT_SELECTION })
          expect(error.http_status).to eq(:unprocessable_entity)
        end
      end

      it 'returns an array user_ids:error codes - 2 validation failures' do
        registration = FactoryBot.create(:registration)
        registration2 = FactoryBot.create(:registration)
        registration3 = FactoryBot.create(:registration)

        failed_update = FactoryBot.build(:update_request, user_id: registration[:user_id], competing: { 'event_ids' => [] })
        normal_update = FactoryBot.build(:update_request, user_id: registration2[:user_id], competing: { 'status' => 'accepted' })
        failed_update2 = FactoryBot.build(:update_request, user_id: registration3[:user_id], competing: { 'status' => 'random_status' })
        updates = [failed_update, normal_update, failed_update2]
        bulk_update_request = FactoryBot.build(:bulk_update_request, requests: updates)

        competition_info = CompetitionInfo.new(FactoryBot.build(:competition))

        error_json = {
          registration[:user_id] => ErrorCodes::INVALID_EVENT_SELECTION,
          registration3[:user_id] => ErrorCodes::INVALID_REQUEST_DATA,
        }

        expect {
          RegistrationChecker.bulk_update_allowed!(bulk_update_request, competition_info, bulk_update_request['submitted_by'])
        }.to raise_error(BulkUpdateError) do |error|
          expect(error.errors).to eq(error_json)
          expect(error.http_status).to eq(:unprocessable_entity)
        end
      end

      it 'returns an error if the registration isnt found' do
        registration = FactoryBot.create(:registration)
        missing_registration_user_id = (registration[:user_id]-1)
        failed_update = FactoryBot.build(:update_request, user_id: missing_registration_user_id)
        bulk_update_request = FactoryBot.build(:bulk_update_request, requests: [failed_update])

        competition_info = CompetitionInfo.new(FactoryBot.build(:competition))

        error_json = {
          missing_registration_user_id => ErrorCodes::REGISTRATION_NOT_FOUND,
        }

        expect {
          RegistrationChecker.bulk_update_allowed!(bulk_update_request, competition_info, bulk_update_request['submitted_by'])
        }.to raise_error(BulkUpdateError) do |error|
          expect(error.errors).to eq(error_json)
          expect(error.http_status).to eq(:unprocessable_entity)
        end
      end

      it 'returns errors array - validation failure and reg not found' do
        registration = FactoryBot.create(:registration)
        registration2 = FactoryBot.create(:registration)
        registration3 = FactoryBot.create(:registration)

        failed_update = FactoryBot.build(:update_request, user_id: registration[:user_id], competing: { 'event_ids' => [] })
        normal_update = FactoryBot.build(:update_request, user_id: registration2[:user_id], competing: { 'status' => 'accepted' })

        missing_registration_user_id = (registration3[:user_id].to_i-1)
        failed_update2 = FactoryBot.build(:update_request, user_id: missing_registration_user_id)
        updates = [failed_update, normal_update, failed_update2]
        bulk_update_request = FactoryBot.build(:bulk_update_request, requests: updates)

        competition_info = CompetitionInfo.new(FactoryBot.build(:competition))

        error_json = {
          registration[:user_id] => ErrorCodes::INVALID_EVENT_SELECTION,
          missing_registration_user_id => ErrorCodes::REGISTRATION_NOT_FOUND,
        }

        expect {
          RegistrationChecker.bulk_update_allowed!(bulk_update_request, competition_info, bulk_update_request['submitted_by'])
        }.to raise_error(BulkUpdateError) do |error|
          expect(error.errors).to eq(error_json)
          expect(error.http_status).to eq(:unprocessable_entity)
        end
      end
    end
  end
end
