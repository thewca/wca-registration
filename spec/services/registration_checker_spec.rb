# frozen_string_literal: true

require 'rails_helper'
require_relative '../../app/helpers/competition_api'

# TODO: Add a test where one comp has a lot of competitors and another doesnt but you can still accept, to ensure that we're checking the reg count
# for the COMPETITION, not all registrations

RSpec.shared_examples 'invalid user status updates' do |old_status, new_status|
  it "user cant change 'status' => #{old_status} to: #{new_status}" do
    registration = FactoryBot.create(:registration, registration_status: old_status)
    competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
    update_request = FactoryBot.build(:update_request, user_id: registration[:user_id], competing: { 'status' => new_status })

    expect {
      RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by'])
    }.to raise_error(RegistrationError) do |error|
      expect(error.http_status).to eq(:unauthorized)
      expect(error.error).to eq(ErrorCodes::USER_INSUFFICIENT_PERMISSIONS)
    end
  end
end

RSpec.shared_examples 'valid organizer status updates' do |old_status, new_status|
  it "admin can change 'status' => #{old_status} to: #{new_status} before close" do
    registration = FactoryBot.create(:registration, registration_status: old_status)
    competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
    update_request = FactoryBot.build(:update_request, :organizer_for_user, user_id: registration[:user_id], competing: { 'status' => new_status })

    expect { RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by']) }
      .not_to raise_error
  end

  it "after edit deadline/reg close, organizer can change 'status' => #{old_status} to: #{new_status}" do
    registration = FactoryBot.create(:registration, registration_status: old_status)
    competition_info = CompetitionInfo.new(FactoryBot.build(:competition, :closed))
    update_request = FactoryBot.build(:update_request, :organizer_for_user, user_id: registration[:user_id], competing: { 'status' => new_status })

    expect { RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by']) }
      .not_to raise_error
  end
end

describe RegistrationChecker do
  describe '#create_registration_allowed!' do
    it 'user must have events selected' do
      registration_request = FactoryBot.build(:registration_request, events: [])
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))

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

      expect { RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request['submitted_by']) }
        .not_to raise_error
    end

    it 'guests may equal 0' do
      registration_request = FactoryBot.build(:registration_request, guests: 0)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))

      expect { RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request['submitted_by']) }
        .not_to raise_error
    end

    it 'guests cant exceed 0 if not allowed' do
      registration_request = FactoryBot.build(:registration_request, guests: 2)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition, guests_per_registration_limit: 0))

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

      expect { RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request['submitted_by']) }
        .not_to raise_error
    end

    it 'comment can be blank' do
      comment = ''
      registration_request = FactoryBot.build(:registration_request, :comment, raw_comment: comment)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))

      expect { RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request['submitted_by']) }
        .not_to raise_error
    end

    it 'comment must be included if required' do
      registration_request = FactoryBot.build(:registration_request)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition, force_comment_in_registration: true))

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

      expect {
        RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request['submitted_by'])
      }.to raise_error(RegistrationError) do |error|
        expect(error.http_status).to eq(:unprocessable_entity)
        expect(error.error).to eq(ErrorCodes::REQUIRED_COMMENT_MISSING)
      end
    end
  end

  describe '#create_registration_allowed!.validate_qualifications!' do
    it 'smoketest - succeeds when all qualifications are met' do
      # Create a competition with ranking qualification enabled but not enforced
      @competition = FactoryBot.build(:competition, :has_qualifications)
      @competition_info = CompetitionInfo.new(@competition.except('qualifications'))

      # Mock the qualification endpoint
      stub_request(:get, comp_api_url("#{@competition['id']}/qualifications")).to_return(status: 200, body: @competition['qualifications'].to_json)

      registration_request = FactoryBot.build(:registration_request, user_id: 1002, events: ['222', '333', '555', '555bf', '333mbf', '444', 'pyram', 'minx']) # User id returns nil for personal records

      expect {
        RegistrationChecker.create_registration_allowed!(registration_request, @competition_info, registration_request['submitted_by'])
      }.not_to raise_error
    end

    RSpec.shared_examples 'succeed: qualification not enforced' do |description, user_id, event_ids|
      it "succeeds given #{description}" do
        # Create a competition with ranking qualification enabled but not enforced
        competition = FactoryBot.build(:competition, :has_qualifications, :qualifications_not_enforced)
        competition_info = CompetitionInfo.new(competition.except('qualifications'))

        # Mock the qualification endpoint
        stub_request(:get, comp_api_url("#{competition['id']}/qualifications")).to_return(status: 200, body: competition['qualifications'].to_json)

        registration_request = FactoryBot.build(:registration_request, user_id: user_id, events: event_ids)

        expect {
          RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request['submitted_by'])
        }.not_to raise_error
      end
    end

    RSpec.shared_examples 'succeed: qualification enforced' do |description, user_id, event_ids|
      it "succeeds given given #{description}" do
        # Create a competition with ranking qualification enabled but not enforced
        competition = FactoryBot.build(:competition, :has_qualifications)
        competition_info = CompetitionInfo.new(competition.except('qualifications'))

        # Mock the qualification endpoint
        stub_request(:get, comp_api_url("#{competition['id']}/qualifications")).to_return(status: 200, body: competition['qualifications'].to_json)

        registration_request = FactoryBot.build(:registration_request, user_id: user_id, events: event_ids)

        expect {
          RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request['submitted_by'])
        }.not_to raise_error
      end
    end

    RSpec.shared_examples 'fail: qualification enforced' do |description, user_id, event_ids|
      it "fails given #{description}" do
        # Create a competition with ranking qualification enabled but not enforced
        competition = FactoryBot.build(:competition, :has_qualifications)
        competition_info = CompetitionInfo.new(competition.except('qualifications'))

        # Mock the qualification endpoint
        stub_request(:get, comp_api_url("#{competition['id']}/qualifications")).to_return(status: 200, body: competition['qualifications'].to_json)

        registration_request = FactoryBot.build(:registration_request, user_id: user_id, events: event_ids)

        expect {
          RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.error).to eq(ErrorCodes::QUALIFICATION_NOT_MET)
          expect(error.http_status).to eq(:unprocessable_entity)
        end
      end
    end

    context 'succeed: qualification not enforced' do
      it_behaves_like 'succeed: qualification not enforced', 'no error when nil 333 for attemptResult-single', 1001, ['333']
      it_behaves_like 'succeed: qualification not enforced', 'no error when nil 555 for attemptResult-average', 1001, ['555']
      it_behaves_like 'succeed: qualification not enforced', 'no error when nil 222 for anyResult-single', 1001, ['222']
      it_behaves_like 'succeed: qualification not enforced', 'no error when nil 555bf for anyResult-average', 1001, ['555bf']
      it_behaves_like 'succeed: qualification not enforced', 'no error when nil pyram for ranking-single', 1001, ['pyram']
      it_behaves_like 'succeed: qualification not enforced', 'no error when nil minx for ranking-average', 1001, ['minx']

      it_behaves_like 'succeed: qualification not enforced', 'no error even though 333 doesnt make quali for attemptResult-single', 1007, ['333']
      it_behaves_like 'succeed: qualification not enforced', 'no error even though 555 doesnt make quali for attemptResult-average', 1008, ['555']
    end

    context 'fail: qualification enforced' do
      it_behaves_like 'fail: qualification enforced', 'cant register when nil 333 for attemptResult-single', 1003, ['333']
      it_behaves_like 'fail: qualification enforced', 'cant register when nil 555 for attemptResult-average', 1004, ['555']
      it_behaves_like 'fail: qualification enforced', 'cant register when nil 222 for anyResult-single', 1005, ['222']
      it_behaves_like 'fail: qualification enforced', 'cant register when nil 555bf for anyResult-average', 1006, ['555bf']
      it_behaves_like 'fail: qualification enforced', 'cant register when nil pyram for ranking-single', 10061, ['pyram']
      it_behaves_like 'fail: qualification enforced', 'cant register when nil minx for ranking-average', 10062, ['minx']

      it_behaves_like 'fail: qualification enforced', 'cant register when 333 slower than attemptResult-single', 1007, ['333']
      it_behaves_like 'fail: qualification enforced', 'cant register when 333 equal to attemptResult-single', 1009, ['333']
      it_behaves_like 'fail: qualification enforced', 'cant register when 555 slower than attemptResult-average', 1008, ['555']
      it_behaves_like 'fail: qualification enforced', 'cant register when 555 equal to attemptResult-average', 1010, ['555']
    end

    context 'succeed: qualification enforced' do
      it_behaves_like 'succeed: qualification enforced', 'can register when 333 faster than attemptResult-single', 1011, ['333']
      it_behaves_like 'succeed: qualification enforced', 'can register when 555 faster than attemptResult-average', 1012, ['555']

      it_behaves_like 'succeed: qualification enforced', 'can register when 222 single exists for anyResult-single', 1013, ['222']
      it_behaves_like 'succeed: qualification enforced', 'can register when 555bf average exists for anyResult-average', 1014, ['555bf']

      it_behaves_like 'succeed: qualification enforced', 'can register when pyram single exists for ranking-single', 1015, ['pyram']
      it_behaves_like 'succeed: qualification enforced', 'can register when 555bf average exists for ranking-average', 1016, ['minx']
    end
  end

  describe '#create_registration_allowed!.user_can_create_registration!' do
    it 'user can create a registration' do
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
      registration_request = FactoryBot.build(:registration_request)

      expect { RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request['submitted_by']) }
        .not_to raise_error
    end

    it 'users can only register for themselves' do
      registration_request = FactoryBot.build(:registration_request, :impersonation)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))

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

      expect { RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request['submitted_by']) }
        .not_to raise_error
    end

    it 'organizers can create registrations for users' do
      registration_request = FactoryBot.build(:registration_request, :organizer_submits)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))

      expect { RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request['submitted_by']) }
        .not_to raise_error
    end

    it 'organizers cant register another user before registration opens' do
      registration_request = FactoryBot.build(:registration_request, :organizer_submits)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition, :closed))

      expect {
        RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request['submitted_by'])
      }.to raise_error(RegistrationError) do |error|
        expect(error.http_status).to eq(:forbidden)
        expect(error.error).to eq(ErrorCodes::REGISTRATION_CLOSED)
      end
    end

    it 'banned user cant register' do
      registration_request = FactoryBot.build(:registration_request, :banned)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))

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

      expect {
        RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request['submitted_by'])
      }.to raise_error(RegistrationError) do |error|
        expect(error.http_status).to eq(:unauthorized)
        expect(error.error).to eq(ErrorCodes::USER_CANNOT_COMPETE)
      end
    end

    it 'organizer cant register a banned user' do
      registration_request = FactoryBot.build(:registration_request, :banned, :organizer_submits)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))

      expect {
        RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request['submitted_by'])
      }.to raise_error(RegistrationError) do |error|
        expect(error.http_status).to eq(:unauthorized)
        expect(error.error).to eq(ErrorCodes::USER_CANNOT_COMPETE)
      end
    end

    it 'organizer cant register an incomplete user' do
      registration_request = FactoryBot.build(:registration_request, :incomplete, :organizer_submits)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))

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

      expect {
        RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request['submitted_by'])
      }.not_to raise_error
    end

    it 'cant register if already have a non-cancelled registration for another series competition' do
      registration_request = FactoryBot.build(:registration_request)
      FactoryBot.create(:registration, user_id: registration_request['user_id'], registration_status: 'accepted', competition_id: 'CubingZAWarmup2023')
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition, :series))

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

      expect {
        RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request['submitted_by'])
      }.not_to raise_error
    end

    it 'cant re-register (register after cancelling) if they have a registration for another series comp' do
      registration = FactoryBot.create(:registration, registration_status: 'cancelled')
      FactoryBot.create(:registration, user_id: registration['user_id'], registration_status: 'accepted', competition_id: 'CubingZAWarmup2023')
      update_request = FactoryBot.build(:update_request, user_id: registration[:user_id], competing: { 'status' => 'pending' })
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition, :series))

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

      expect { RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request['submitted_by']) }
        .not_to raise_error
    end

    it 'competitor cant register more events than the events_per_registration_limit' do
      registration_request = FactoryBot.build(:registration_request, events: ['333', '222', '444', '555', '666', '777'])
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition, events_per_registration_limit: 5))

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

      expect {
        RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request['submitted_by'])
      }.to raise_error(RegistrationError) do |error|
        expect(error.http_status).to eq(:forbidden)
        expect(error.error).to eq(ErrorCodes::INVALID_EVENT_SELECTION)
      end
    end
  end

  describe '#update_registration_allowed!.validate_qualifications!' do
    it 'smoketest - succeeds when all qualifications are met' do
      # Create a competition with ranking qualification enabled but not enforced
      @competition = FactoryBot.build(:competition, :has_qualifications)
      @competition_info = CompetitionInfo.new(@competition.except('qualifications'))

      # Mock the qualification endpoint
      stub_request(:get, comp_api_url("#{@competition['id']}/qualifications")).to_return(status: 200, body: @competition['qualifications'].to_json)

      update_request = FactoryBot.build(
        :update_request, user_id: 1002, competing: { 'event_ids' => ['222', '333', '555', '555bf', '333mbf', '444', 'pyram', 'minx'] }
      )
      FactoryBot.create(:registration, user_id: update_request['user_id'])

      expect {
        RegistrationChecker.update_registration_allowed!(update_request, @competition_info, update_request['submitted_by'])
      }.not_to raise_error
    end

    RSpec.shared_examples 'update succeed: qualification not enforced' do |description, user_id, event_ids|
      it "succeeds given #{description}" do
        # Create a competition with ranking qualification enabled but not enforced
        competition = FactoryBot.build(:competition, :has_qualifications, :qualifications_not_enforced)
        competition_info = CompetitionInfo.new(competition.except('qualifications'))

        # Mock the qualification endpoint
        stub_request(:get, comp_api_url("#{competition['id']}/qualifications")).to_return(status: 200, body: competition['qualifications'].to_json)

        update_request = FactoryBot.build(:update_request, user_id: user_id, competing: { 'event_ids' => event_ids })
        FactoryBot.create(:registration, user_id: update_request['user_id'])

        expect {
          RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by'])
        }.not_to raise_error
      end
    end

    RSpec.shared_examples 'update succeed: qualification enforced' do |description, user_id, event_ids|
      it "succeeds given given #{description}" do
        # Create a competition with ranking qualification enabled but not enforced
        competition = FactoryBot.build(:competition, :has_qualifications)
        competition_info = CompetitionInfo.new(competition.except('qualifications'))

        # Mock the qualification endpoint
        stub_request(:get, comp_api_url("#{competition['id']}/qualifications")).to_return(status: 200, body: competition['qualifications'].to_json)

        update_request = FactoryBot.build(:update_request, user_id: user_id, competing: { 'event_ids' => event_ids })
        FactoryBot.create(:registration, user_id: update_request['user_id'])

        expect {
          RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by'])
        }.not_to raise_error
      end
    end

    RSpec.shared_examples 'update fail: qualification enforced' do |description, user_id, event_ids|
      it "fails given #{description}" do
        # Create a competition with ranking qualification enabled but not enforced
        competition = FactoryBot.build(:competition, :has_qualifications)
        competition_info = CompetitionInfo.new(competition.except('qualifications'))

        # Mock the qualification endpoint
        stub_request(:get, comp_api_url("#{competition['id']}/qualifications")).to_return(status: 200, body: competition['qualifications'].to_json)

        update_request = FactoryBot.build(:update_request, user_id: user_id, competing: { 'event_ids' => event_ids })
        FactoryBot.create(:registration, user_id: update_request['user_id'])

        expect {
          RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by'])
        }.to raise_error(RegistrationError) do |error|
          expect(error.error).to eq(ErrorCodes::QUALIFICATION_NOT_MET)
          expect(error.http_status).to eq(:unprocessable_entity)
        end
      end
    end

    context 'succeed: qualification not enforced' do
      # The competition in the shared example has the necessary qualifications set up
      # Thus, we don't have to define the qualification for each example, just the event relating to the qualification under test
      it_behaves_like 'update succeed: qualification not enforced', 'no error when nil 333 for attemptResult-single', 1001, ['333']
      it_behaves_like 'update succeed: qualification not enforced', 'no error when nil 555 for attemptResult-average', 1001, ['555']
      it_behaves_like 'update succeed: qualification not enforced', 'no error when nil 222 for anyResult-single', 1001, ['222']
      it_behaves_like 'update succeed: qualification not enforced', 'no error when nil 555bf for anyResult-average', 1001, ['555bf']
      it_behaves_like 'update succeed: qualification not enforced', 'no error when nil 555bf for anyResult-average', 1001, ['pyram']
      it_behaves_like 'update succeed: qualification not enforced', 'no error when nil 555bf for anyResult-average', 1001, ['minx']

      it_behaves_like 'update succeed: qualification not enforced', 'no error even though 333 doesnt make quali for attemptResult-single', 1007, ['333']
      it_behaves_like 'update succeed: qualification not enforced', 'no error even though 555 doesnt make quali for attemptResult-average', 1008, ['555']
    end

    context 'fail: qualification enforced' do
      it_behaves_like 'update fail: qualification enforced', 'cant register when nil 333 for attemptResult-single', 1003, ['333']
      it_behaves_like 'update fail: qualification enforced', 'cant register when nil 555 for attemptResult-average', 1004, ['555']
      it_behaves_like 'update fail: qualification enforced', 'cant register when nil 222 for anyResult-single', 1005, ['222']
      it_behaves_like 'update fail: qualification enforced', 'cant register when nil 555bf for anyResult-average', 1006, ['555bf']
      it_behaves_like 'update fail: qualification enforced', 'cant register when nil pyram for ranking-single', 10061, ['pyram']
      it_behaves_like 'update fail: qualification enforced', 'cant register when nil minx for ranking-average', 10062, ['minx']

      it_behaves_like 'update fail: qualification enforced', 'cant register when 333 slower than attemptResult-single', 1007, ['333']
      it_behaves_like 'update fail: qualification enforced', 'cant register when 333 equal to attemptResult-single', 1009, ['333']
      it_behaves_like 'update fail: qualification enforced', 'cant register when 555 slower than attemptResult-average', 1008, ['555']
      it_behaves_like 'update fail: qualification enforced', 'cant register when 555 equal to attemptResult-average', 1010, ['555']
    end

    context 'succeed: qualification enforced' do
      it_behaves_like 'update succeed: qualification enforced', 'can register when 333 faster than attemptResult-single', 1011, ['333']
      it_behaves_like 'update succeed: qualification enforced', 'can register when 555 faster than attemptResult-average', 1012, ['555']

      it_behaves_like 'update succeed: qualification enforced', 'can register when 222 single exists for anyResult-single', 1013, ['222']
      it_behaves_like 'update succeed: qualification enforced', 'can register when 555bf average exists for anyResult-average', 1014, ['555bf']

      it_behaves_like 'update succeed: qualification enforced', 'can register when pyram average exists for ranking-single', 1015, ['pyram']
      it_behaves_like 'update succeed: qualification enforced', 'can register when minx average exists for ranking-average', 1016, ['minx']
    end
  end

  describe '#update_registration_allowed!.user_can_modify_registration!' do
    it 'raises error if registration doesnt exist' do
      registration = FactoryBot.create(:registration)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
      update_request = FactoryBot.build(:update_request, user_id: (registration[:user_id] -1))

      expect {
        RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by'])
      }.to raise_error(RegistrationError) do |error|
        expect(error.error).to eq(ErrorCodes::REGISTRATION_NOT_FOUND)
        expect(error.http_status).to eq(:not_found)
      end
    end

    it 'user can change their registration' do
      registration = FactoryBot.create(:registration)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
      update_request = FactoryBot.build(:update_request, user_id: registration[:user_id])

      expect { RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by']) }
        .not_to raise_error
    end

    it 'User A cant change User Bs registration' do
      registration = FactoryBot.create(:registration)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
      update_request = FactoryBot.build(:update_request, :for_another_user, user_id: registration[:user_id])

      expect {
        RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by'])
      }.to raise_error(RegistrationError) do |error|
        expect(error.http_status).to eq(:unauthorized)
        expect(error.error).to eq(ErrorCodes::USER_INSUFFICIENT_PERMISSIONS)
      end
    end

    it 'user cant update registration if registration edits arent allowed' do
      registration = FactoryBot.create(:registration)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition, allow_registration_edits: false))
      update_request = FactoryBot.build(:update_request, user_id: registration[:user_id])

      expect {
        RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by'])
      }.to raise_error(RegistrationError) do |error|
        expect(error.http_status).to eq(:forbidden)
        expect(error.error).to eq(ErrorCodes::USER_EDITS_NOT_ALLOWED)
      end
    end

    it 'user cant change events after event change deadline' do
      registration = FactoryBot.create(:registration)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition, :event_change_deadline_passed))
      update_request = FactoryBot.build(:update_request, user_id: registration[:user_id], competing: { 'event_ids' => ['333', '444', '555'] })

      expect {
        RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by'])
      }.to raise_error(RegistrationError) do |error|
        expect(error.http_status).to eq(:forbidden)
        expect(error.error).to eq(ErrorCodes::USER_EDITS_NOT_ALLOWED)
      end
    end

    it 'organizer can change user registration' do
      registration = FactoryBot.create(:registration)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
      update_request = FactoryBot.build(:update_request, :organizer_for_user, user_id: registration[:user_id])

      expect { RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by']) }
        .not_to raise_error
    end

    it 'organizer can change registration after change deadline' do
      registration = FactoryBot.create(:registration)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition, :event_change_deadline_passed))
      update_request = FactoryBot.build(:update_request, :organizer_for_user, user_id: registration[:user_id], competing: { 'comment' => 'this is a new comment' })

      expect { RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by']) }
        .not_to raise_error
    end
  end

  describe '#update_registration_allowed!.validate_comment!' do
    it 'user can change comment' do
      registration = FactoryBot.create(:registration, 'comment' => 'old comment')
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
      update_request = FactoryBot.build(:update_request, user_id: registration[:user_id], competing: { 'comment' => 'new comment' })

      expect { RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by']) }
        .not_to raise_error
    end

    it 'user cant exceed comment length' do
      long_comment = 'comment longer than 240 characterscomment longer than 240 characterscomment longer than 240 characterscomment longer than 240 characterscomment longer than 240 characterscomment longer than 240 characterscomment longer
        than 240 characterscomment longer than 240 characters'

      registration = FactoryBot.create(:registration)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
      update_request = FactoryBot.build(:update_request, user_id: registration[:user_id], competing: { 'comment' => long_comment })

      expect {
        RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by'])
      }.to raise_error(RegistrationError) do |error|
        expect(error.http_status).to eq(:unprocessable_entity)
        expect(error.error).to eq(ErrorCodes::USER_COMMENT_TOO_LONG)
      end
    end

    it 'user can match comment length' do
      at_character_limit = 'comment longer than 240 characterscomment longer than 240 characterscomment longer than 240 characterscomment longer than 240 characterscomment longer than 240 characterscomment longer than' \
                           '240 characterscomment longer longer than 240 12345'

      registration = FactoryBot.create(:registration)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
      update_request = FactoryBot.build(:update_request, user_id: registration[:user_id], competing: { 'comment' => at_character_limit })

      expect { RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by']) }
        .not_to raise_error
    end

    it 'comment can be blank' do
      registration = FactoryBot.create(:registration)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
      update_request = FactoryBot.build(:update_request, user_id: registration[:user_id], competing: { 'comment' => '' })

      expect { RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by']) }
        .not_to raise_error
    end

    it 'comment cant be blank if required' do
      registration = FactoryBot.create(:registration)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition, force_comment_in_registration: true))
      update_request = FactoryBot.build(:update_request, user_id: registration[:user_id], competing: { 'comment' => '' })

      expect {
        RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by'])
      }.to raise_error(RegistrationError) do |error|
        expect(error.http_status).to eq(:unprocessable_entity)
        expect(error.error).to eq(ErrorCodes::REQUIRED_COMMENT_MISSING)
      end
    end

    it 'mandatory comment: updates without comments are allowed as long as a comment already exists in the registration' do
      registration = FactoryBot.create(:registration, comment: 'this is a test comment')
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition, force_comment_in_registration: true))
      update_request = FactoryBot.build(:update_request, user_id: registration[:user_id], competing: { 'status' => 'cancelled' })

      expect { RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by']) }
        .not_to raise_error
    end

    it 'oranizer can change registration state when comment is mandatory' do
      registration = FactoryBot.create(:registration, comment: 'this is a test comment')
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition, force_comment_in_registration: true))
      update_request = FactoryBot.build(:update_request, :organizer_for_user, user_id: registration[:user_id], competing: { 'status' => 'accepted' })

      expect { RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by']) }
        .not_to raise_error
    end

    it 'organizer can change user comment' do
      registration = FactoryBot.create(:registration, 'comment' => 'original comment')
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
      update_request = FactoryBot.build(:update_request, :organizer_for_user, user_id: registration[:user_id], competing: { 'comment' => '' })

      expect { RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by']) }
        .not_to raise_error
    end

    it 'organizer cant exceed comment length' do
      long_comment = 'comment longer than 240 characterscomment longer than 240 characterscomment longer than 240 characterscomment longer than 240 characterscomment longer than 240 characterscomment longer than 240 characterscomment longer
        than 240 characterscomment longer than 240 characters'

      registration = FactoryBot.create(:registration)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
      update_request = FactoryBot.build(:update_request, :organizer_for_user, user_id: registration[:user_id], competing: { 'comment' => long_comment })

      expect {
        RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by'])
      }.to raise_error(RegistrationError) do |error|
        expect(error.http_status).to eq(:unprocessable_entity)
        expect(error.error).to eq(ErrorCodes::USER_COMMENT_TOO_LONG)
      end
    end

    it 'user cant change comment after edit events deadline' do
      registration = FactoryBot.create(:registration)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition, :event_change_deadline_passed))
      update_request = FactoryBot.build(:update_request, user_id: registration[:user_id], competing: { 'comment' => 'this is a new comment' })

      expect {
        RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by'])
      }.to raise_error(RegistrationError) do |error|
        expect(error.http_status).to eq(:forbidden)
        expect(error.error).to eq(ErrorCodes::USER_EDITS_NOT_ALLOWED)
      end
    end
  end

  describe '#update_registration_allowed!.validate_organizer_fields!' do
    it 'organizer can add organizer_comment' do
      registration = FactoryBot.create(:registration)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
      update_request = FactoryBot.build(:update_request, :organizer_for_user, user_id: registration[:user_id], competing: { 'organizer_comment' => 'this is an admin comment' })

      expect { RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by']) }
        .not_to raise_error
    end

    it 'organizer can change organizer_comment' do
      registration = FactoryBot.create(:registration, 'organizer_comment' => 'old admin comment')
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
      update_request = FactoryBot.build(:update_request, :organizer_for_user, user_id: registration[:user_id], competing: { 'organizer_comment' => 'new admin comment' })

      expect { RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by']) }
        .not_to raise_error
    end

    it 'user cant submit an organizer comment' do
      registration = FactoryBot.create(:registration)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
      update_request = FactoryBot.build(:update_request, user_id: registration[:user_id], competing: { 'organizer_comment' => 'new admin comment' })

      expect {
        RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by'])
      }.to raise_error(RegistrationError) do |error|
        expect(error.http_status).to eq(:unauthorized)
        expect(error.error).to eq(ErrorCodes::USER_INSUFFICIENT_PERMISSIONS)
      end
    end

    it 'user cant submit waiting_list_position' do
      registration = FactoryBot.create(:registration)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
      update_request = FactoryBot.build(:update_request, user_id: registration[:user_id], competing: { 'waiting_list_position' => '1' })

      expect {
        RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by'])
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

      registration = FactoryBot.create(:registration)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
      update_request = FactoryBot.build(:update_request, :organizer_for_user, user_id: registration[:user_id], competing: { 'organizer_comment' => long_comment })

      expect {
        RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by'])
      }.to raise_error(RegistrationError) do |error|
        expect(error.http_status).to eq(:unprocessable_entity)
        expect(error.error).to eq(ErrorCodes::USER_COMMENT_TOO_LONG)
      end
    end

    it 'organizer comment can match 240 characters' do
      at_character_limit = 'comment longer than 240 characterscomment longer than 240 characterscomment longer than 240 characterscomment longer than 240 characterscomment longer than 240 characterscomment longer than' \
                           '240 characterscomment longer longer than 240 12345'

      registration = FactoryBot.create(:registration)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
      update_request = FactoryBot.build(:update_request, :organizer_for_user, user_id: registration[:user_id], competing: { 'organizer_comment' => at_character_limit })

      expect { RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by']) }
        .not_to raise_error
    end
  end

  describe '#update_registration_allowed!.validate_guests!' do
    it 'user can change number of guests' do
      registration = FactoryBot.create(:registration)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
      update_request = FactoryBot.build(:update_request, user_id: registration[:user_id], guests: 2)

      expect { RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by']) }
        .not_to raise_error
    end

    it 'guests cant exceed guest limit' do
      registration = FactoryBot.create(:registration)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
      update_request = FactoryBot.build(:update_request, user_id: registration[:user_id], guests: 3)

      expect {
        RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by'])
      }.to raise_error(RegistrationError) do |error|
        expect(error.http_status).to eq(:unprocessable_entity)
        expect(error.error).to eq(ErrorCodes::GUEST_LIMIT_EXCEEDED)
      end
    end

    it 'guests can match guest limit' do
      registration = FactoryBot.create(:registration)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
      update_request = FactoryBot.build(:update_request, user_id: registration[:user_id], guests: 2)

      expect { RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by']) }
        .not_to raise_error
    end

    it 'guests can be zero' do
      registration = FactoryBot.create(:registration)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
      update_request = FactoryBot.build(:update_request, user_id: registration[:user_id], guests: 0)

      expect { RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by']) }
        .not_to raise_error
    end

    it 'guests cant be negative' do
      registration = FactoryBot.create(:registration)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
      update_request = FactoryBot.build(:update_request, user_id: registration[:user_id], guests: -1)

      expect {
        RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by'])
      }.to raise_error(RegistrationError) do |error|
        expect(error.http_status).to eq(:unprocessable_entity)
        expect(error.error).to eq(ErrorCodes::INVALID_REQUEST_DATA)
      end
    end

    it 'guests have no limit if guest limit not set' do
      registration = FactoryBot.create(:registration)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition, :no_guest_limit))
      update_request = FactoryBot.build(:update_request, user_id: registration[:user_id], guests: 99)

      expect { RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by']) }
        .not_to raise_error
    end

    it 'organizer can change number of guests' do
      registration = FactoryBot.create(:registration)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
      update_request = FactoryBot.build(:update_request, :organizer_for_user, user_id: registration[:user_id], guests: 2)

      expect { RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by']) }
        .not_to raise_error
    end

    it 'User A cant change User Bs guests' do
      registration = FactoryBot.create(:registration)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
      update_request = FactoryBot.build(:update_request, :for_another_user, user_id: registration[:user_id], guests: 2)

      expect {
        RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by'])
      }.to raise_error(RegistrationError) do |error|
        expect(error.http_status).to eq(:unauthorized)
        expect(error.error).to eq(ErrorCodes::USER_INSUFFICIENT_PERMISSIONS)
      end
    end

    it 'user cant change guests after registration change deadline' do
      registration = FactoryBot.create(:registration)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition, event_change_deadline_date: '2022-06-14T00:00:00.000Z'))
      update_request = FactoryBot.build(:update_request, user_id: registration[:user_id], guests: 2)

      expect {
        RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by'])
      }.to raise_error(RegistrationError) do |error|
        expect(error.http_status).to eq(:forbidden)
        expect(error.error).to eq(ErrorCodes::USER_EDITS_NOT_ALLOWED)
      end
    end

    it 'organizer can change guests after registration change deadline' do
      registration = FactoryBot.create(:registration)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition, event_change_deadline_date: '2022-06-14T00:00:00.000Z'))
      update_request = FactoryBot.build(:update_request, :organizer_for_user, user_id: registration[:user_id], guests: 2)

      expect { RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by']) }
        .not_to raise_error
    end
  end

  describe '#update_registration_allowed!.validate_update_status!' do
    it 'user cant submit an invalid status' do
      registration = FactoryBot.create(:registration, registration_status: 'waiting_list')
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
      update_request = FactoryBot.build(:update_request, user_id: registration[:user_id], competing: { 'status' => 'random_status' })

      expect {
        RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by'])
      }.to raise_error(RegistrationError) do |error|
        expect(error.http_status).to eq(:unprocessable_entity)
        expect(error.error).to eq(ErrorCodes::INVALID_REQUEST_DATA)
      end
    end

    it 'organizer cant submit an invalid status' do
      registration = FactoryBot.create(:registration, registration_status: 'waiting_list')
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
      update_request = FactoryBot.build(:update_request, :organizer_as_user, user_id: registration[:user_id], competing: { 'status' => 'random_status' })

      expect {
        RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by'])
      }.to raise_error(RegistrationError) do |error|
        expect(error.http_status).to eq(:unprocessable_entity)
        expect(error.error).to eq(ErrorCodes::INVALID_REQUEST_DATA)
      end
    end

    it 'organizer cant accept a user when registration list is full' do
      FactoryBot.create_list(:registration, 3, registration_status: 'accepted')
      registration = FactoryBot.create(:registration, registration_status: 'waiting_list')
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition, competitor_limit: 3))
      update_request = FactoryBot.build(:update_request, :organizer_for_user, user_id: registration[:user_id], competing: { 'status' => 'accepted' })

      expect {
        RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by'])
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
      registration = FactoryBot.create(:registration, registration_status: 'waiting_list')
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
      update_request = FactoryBot.build(:update_request, user_id: registration[:user_id], competing: { 'status' => 'cancelled' })

      expect { RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by']) }
        .not_to raise_error
    end

    it 'user cant change events when cancelling' do
      registration = FactoryBot.create(:registration, registration_status: 'waiting_list')
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
      update_request = FactoryBot.build(
        :update_request, user_id: registration[:user_id], competing: { 'status' => 'cancelled', 'event_ids' => ['333'] }
      )

      expect {
        RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by'])
      }.to raise_error(RegistrationError) do |error|
        expect(error.http_status).to eq(:unprocessable_entity)
        expect(error.error).to eq(ErrorCodes::INVALID_REQUEST_DATA)
      end
    end

    it 'user can change state from cancelled to pending' do
      registration = FactoryBot.create(:registration, registration_status: 'cancelled')
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
      update_request = FactoryBot.build(:update_request, user_id: registration[:user_id], competing: { 'status' => 'pending' })

      expect { RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by']) }
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
      registration = FactoryBot.create(:registration, registration_status: 'accepted')
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition, allow_registration_self_delete_after_acceptance: false))
      update_request = FactoryBot.build(:update_request, user_id: registration[:user_id], competing: { 'status' => 'cancelled' })

      expect {
        RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by'])
      }.to raise_error(RegistrationError) do |error|
        expect(error.http_status).to eq(:unauthorized)
        expect(error.error).to eq(ErrorCodes::ORGANIZER_MUST_CANCEL_REGISTRATION)
      end
    end

    it 'user can cancel non-accepted registration if competition requires organizers to cancel registration' do
      registration = FactoryBot.create(:registration, registration_status: 'waiting_list')
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition, allow_registration_self_delete_after_acceptance: false))
      update_request = FactoryBot.build(:update_request, user_id: registration[:user_id], competing: { 'status' => 'cancelled' })

      expect { RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by']) }
        .not_to raise_error
    end

    it 'user cant cancel registration after registration ends' do
      registration = FactoryBot.create(:registration)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition, :closed))
      update_request = FactoryBot.build(:update_request, user_id: registration[:user_id], competing: { 'status' => 'cancelled' })

      expect {
        RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by'])
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
      registration = FactoryBot.create(:registration)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition, :closed))
      update_request = FactoryBot.build(:update_request, :organizer_for_user, user_id: registration[:user_id], competing: { 'status' => 'cancelled' })

      expect { RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by']) }
        .not_to raise_error
    end
  end

  describe '#update_registration_allowed!.validate_update_events!' do
    it 'user can add events' do
      registration = FactoryBot.create(:registration)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
      update_request = FactoryBot.build(
        :update_request, user_id: registration[:user_id], competing: { 'event_ids' => ['333', '444', '555', '333mbf'] }
      )

      expect { RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by']) }
        .not_to raise_error
    end

    it 'user can remove events' do
      registration = FactoryBot.create(:registration)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
      update_request = FactoryBot.build(
        :update_request, user_id: registration[:user_id], competing: { 'event_ids' => ['333'] }
      )

      expect { RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by']) }
        .not_to raise_error
    end

    it 'user can remove all old events and register for new ones' do
      registration = FactoryBot.create(:registration)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
      update_request = FactoryBot.build(
        :update_request, user_id: registration[:user_id], competing: { 'event_ids' => ['777', '333bf'] }
      )

      expect { RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by']) }
        .not_to raise_error
    end

    it 'events list cant be blank' do
      registration = FactoryBot.create(:registration)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
      update_request = FactoryBot.build(:update_request, user_id: registration[:user_id], competing: { 'event_ids' => [] })

      expect {
        RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by'])
      }.to raise_error(RegistrationError) do |error|
        expect(error.http_status).to eq(:unprocessable_entity)
        expect(error.error).to eq(ErrorCodes::INVALID_EVENT_SELECTION)
      end
    end

    it 'events must be held at the competition' do
      registration = FactoryBot.create(:registration)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
      update_request = FactoryBot.build(:update_request, user_id: registration[:user_id], competing: { 'event_ids' => ['333fm', '333'] })

      expect {
        RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by'])
      }.to raise_error(RegistrationError) do |error|
        expect(error.http_status).to eq(:unprocessable_entity)
        expect(error.error).to eq(ErrorCodes::INVALID_EVENT_SELECTION)
      end
    end

    it 'events must exist' do
      registration = FactoryBot.create(:registration)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
      update_request = FactoryBot.build(:update_request, user_id: registration[:user_id], competing: { 'event_ids' => ['888', '333'] })

      expect {
        RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by'])
      }.to raise_error(RegistrationError) do |error|
        expect(error.http_status).to eq(:unprocessable_entity)
        expect(error.error).to eq(ErrorCodes::INVALID_EVENT_SELECTION)
      end
    end

    it 'organizer can change a users events' do
      registration = FactoryBot.create(:registration)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
      update_request = FactoryBot.build(
        :update_request, :organizer_for_user, user_id: registration[:user_id], competing: { 'event_ids' => ['333', '666'] }
      )

      expect { RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by']) }
        .not_to raise_error
    end

    it 'organizer cant change users events to events not held at competition' do
      registration = FactoryBot.create(:registration)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
      update_request = FactoryBot.build(
        :update_request, :organizer_for_user, user_id: registration[:user_id], competing: { 'event_ids' => ['333fm', '333'] }
      )

      expect {
        RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by'])
      }.to raise_error(RegistrationError) do |error|
        expect(error.http_status).to eq(:unprocessable_entity)
        expect(error.error).to eq(ErrorCodes::INVALID_EVENT_SELECTION)
      end
    end

    it 'competitor can update registration with events up to the events_per_registration_limit limit' do
      registration = FactoryBot.create(:registration)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition, events_per_registration_limit: 5))
      update_request = FactoryBot.build(:update_request, user_id: registration[:user_id], competing: { 'event_ids' => ['333', '222', '444', '555', '666'] })

      expect { RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by']) }
        .not_to raise_error
    end

    it 'competitor cant update registration to more events than the events_per_registration_limit' do
      registration = FactoryBot.create(:registration)
      update_request = FactoryBot.build(:update_request, user_id: registration[:user_id], competing: { 'event_ids' => ['333', '222', '444', '555', '666', '777'] })
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition, events_per_registration_limit: 5))

      expect {
        RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by'])
      }.to raise_error(RegistrationError) do |error|
        expect(error.http_status).to eq(:forbidden)
        expect(error.error).to eq(ErrorCodes::INVALID_EVENT_SELECTION)
      end
    end

    it 'organizer cant update their registration with more events than the events_per_registration_limit' do
      registration = FactoryBot.create(:registration)
      update_request = FactoryBot.build(
        :update_request, user_id: registration[:user_id], competing: { 'event_ids' => ['333', '222', '444', '555', '666', '777'] }
      )
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition, events_per_registration_limit: 5))

      expect {
        RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by'])
      }.to raise_error(RegistrationError) do |error|
        expect(error.http_status).to eq(:forbidden)
        expect(error.error).to eq(ErrorCodes::INVALID_EVENT_SELECTION)
      end
    end
  end

  describe '#update_registration_allowed!.validate_waiting_list_position!' do
    it 'must be an integer, not string' do
      registration = FactoryBot.create(:registration)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
      update_request = FactoryBot.build(:update_request, :organizer_for_user, user_id: registration[:user_id], competing: { 'waiting_list_position' => 'b' })

      expect {
        RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by'])
      }.to raise_error(RegistrationError) do |error|
        expect(error.http_status).to eq(:unprocessable_entity)
        expect(error.error).to eq(ErrorCodes::INVALID_WAITING_LIST_POSITION)
      end
    end

    it 'can be an integer given as a string' do
      registration = FactoryBot.create(:registration)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
      update_request = FactoryBot.build(:update_request, :organizer_for_user, user_id: registration[:user_id], competing: { 'waiting_list_position' => '1' })

      expect {
        RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by'])
      }.not_to raise_error
    end

    it 'must be an integer, not float' do
      registration = FactoryBot.create(:registration)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
      update_request = FactoryBot.build(:update_request, :organizer_for_user, user_id: registration[:user_id], competing: { 'waiting_list_position' => 2.0 })

      expect {
        RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by'])
      }.to raise_error(RegistrationError) do |error|
        expect(error.http_status).to eq(:unprocessable_entity)
        expect(error.error).to eq(ErrorCodes::INVALID_WAITING_LIST_POSITION)
      end
    end

    it 'organizer cant accept anyone except the min position on the waiting list' do
      FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => '1')
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
      registration = FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => '2')
      update_request = FactoryBot.build(:update_request, :organizer_for_user, user_id: registration[:user_id], competing: { 'status' => 'accepted' })

      expect {
        RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by'])
      }.to raise_error(RegistrationError) do |error|
        expect(error.http_status).to eq(:forbidden)
        expect(error.error).to eq(ErrorCodes::MUST_ACCEPT_WAITING_LIST_LEADER)
      end
    end

    it 'cannot move to less than current min position' do
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
      registration = FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 1)
      FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 2)
      FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 3)
      FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 4)
      FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 5)

      update_request = FactoryBot.build(:update_request, :organizer_for_user, user_id: registration[:user_id], competing: { 'waiting_list_position' => '10' })

      expect {
        RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by'])
      }.to raise_error(RegistrationError) do |error|
        expect(error.http_status).to eq(:forbidden)
        expect(error.error).to eq(ErrorCodes::INVALID_WAITING_LIST_POSITION)
      end
    end

    it 'cannot move to greater than current max position' do
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
      registration = FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 6)
      FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 2)
      FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 3)
      FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 4)
      FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 5)

      update_request = FactoryBot.build(:update_request, :organizer_for_user, user_id: registration[:user_id], competing: { 'waiting_list_position' => '1' })

      expect {
        RegistrationChecker.update_registration_allowed!(update_request, competition_info, update_request['submitted_by'])
      }.to raise_error(RegistrationError) do |error|
        expect(error.http_status).to eq(:forbidden)
        expect(error.error).to eq(ErrorCodes::INVALID_WAITING_LIST_POSITION)
      end
    end
  end

  describe '#bulk_update_allowed!' do
    it 'only organizers can submit bulk updates' do
      registration = FactoryBot.create(:registration)
      failed_update = FactoryBot.build(:update_request, user_id: registration[:user_id])
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
      bulk_update_request = FactoryBot.build(:bulk_update_request, requests: [failed_update], submitted_by: registration[:user_id])

      expect {
        RegistrationChecker.bulk_update_allowed!(bulk_update_request, competition_info, bulk_update_request['submitted_by'])
      }.to raise_error(RegistrationError) do |error|
        expect(error.error).to eq(ErrorCodes::USER_INSUFFICIENT_PERMISSIONS)
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
