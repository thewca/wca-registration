# frozen_string_literal: true

require 'rails_helper'
require_relative '../../app/helpers/competition_api'

# TODO: Add create test for blank comment submitted with required comment

describe RegistrationChecker do
  describe '#create_registration_allowed!' do
    it 'user can create a registration' do
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
      registration_request = FactoryBot.build(:registration_request)

      # Expect that registration checker will pass
      expect(RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request[:submitted_by])).to be(true)
    end

    it 'users can only register for themselves' do
      registration_request = FactoryBot.build(:registration_request, :impersonation)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))

      expect {
        RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request[:submitted_by])
      }.to raise_error(RegistrationError) do |error|
        expect(error.http_status).to eq(:unauthorized)
        expect(error.error).to eq(ErrorCodes::USER_INSUFFICIENT_PERMISSIONS)
      end
    end

    it 'user cant register if registration is closed' do
      registration_request = FactoryBot.build(:registration_request)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition, :closed))

      expect {
        RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request[:submitted_by])
      }.to raise_error(RegistrationError) do |error|
        expect(error.http_status).to eq(:forbidden)
        expect(error.error).to eq(ErrorCodes::REGISTRATION_CLOSED)
      end
    end

    it 'admins can register before registration opens' do
      registration_request = FactoryBot.build(:registration_request, :admin)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition, :closed))

      expect(RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request[:submitted_by])).to be(true)
    end

    it 'admins can create registrations for users' do
      registration_request = FactoryBot.build(:registration_request, :admin_submits)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))

      expect(RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request[:submitted_by])).to be(true)
    end

    it 'admins cant register another user before registration opens' do
      registration_request = FactoryBot.build(:registration_request, :admin_submits)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition, :closed))

      expect {
        RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request[:submitted_by])
      }.to raise_error(RegistrationError) do |error|
        expect(error.http_status).to eq(:forbidden)
        expect(error.error).to eq(ErrorCodes::REGISTRATION_CLOSED)
      end
    end

    it 'banned user cant register' do
      registration_request = FactoryBot.build(:registration_request, :banned)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))

      expect {
        RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request[:submitted_by])
      }.to raise_error(RegistrationError) do |error|
        expect(error.http_status).to eq(:unauthorized)
        expect(error.error).to eq(ErrorCodes::USER_CANNOT_COMPETE)
      end
    end

    it 'user with incomplete profile cant register' do
      registration_request = FactoryBot.build(:registration_request, :incomplete)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))

      expect {
        RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request[:submitted_by])
      }.to raise_error(RegistrationError) do |error|
        expect(error.http_status).to eq(:unauthorized)
        expect(error.error).to eq(ErrorCodes::USER_CANNOT_COMPETE)
      end
    end

    it 'admin cant register a banned user' do
      registration_request = FactoryBot.build(:registration_request, :banned, :admin_submits)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))

      expect {
        RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request[:submitted_by])
      }.to raise_error(RegistrationError) do |error|
        expect(error.http_status).to eq(:unauthorized)
        expect(error.error).to eq(ErrorCodes::USER_CANNOT_COMPETE)
      end
    end

    it 'admin cant register an incomplete user' do
      registration_request = FactoryBot.build(:registration_request, :incomplete, :admin_submits)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))

      expect {
        RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request[:submitted_by])
      }.to raise_error(RegistrationError) do |error|
        expect(error.http_status).to eq(:unauthorized)
        expect(error.error).to eq(ErrorCodes::USER_CANNOT_COMPETE)
      end
    end

    it 'doesnt leak data if user tries to register for a banned user' do
      registration_request = FactoryBot.build(:registration_request, :banned, :impersonation)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))

      expect {
        RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request[:submitted_by])
      }.to raise_error(RegistrationError) do |error|
        expect(error.http_status).to eq(:unauthorized)
        expect(error.error).to eq(ErrorCodes::USER_INSUFFICIENT_PERMISSIONS)
      end
    end

    it 'doesnt leak data if admin tries to register for a banned user' do
      registration_request = FactoryBot.build(:registration_request, :incomplete, :impersonation)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))

      expect {
        RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request[:submitted_by])
      }.to raise_error(RegistrationError) do |error|
        expect(error.http_status).to eq(:unauthorized)
        expect(error.error).to eq(ErrorCodes::USER_INSUFFICIENT_PERMISSIONS)
      end
    end

    it 'user must have events selected' do
      registration_request = FactoryBot.build(:registration_request, events: [])
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))

      expect {
        RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request[:submitted_by])
      }.to raise_error(RegistrationError) do |error|
        expect(error.http_status).to eq(:unprocessable_entity)
        expect(error.error).to eq(ErrorCodes::INVALID_EVENT_SELECTION)
      end
    end

    it 'events must be held at the competition' do
      registration_request = FactoryBot.build(:registration_request, events: ['333', '333fm'])
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))

      expect {
        RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request[:submitted_by])
      }.to raise_error(RegistrationError) do |error|
        expect(error.http_status).to eq(:unprocessable_entity)
        expect(error.error).to eq(ErrorCodes::INVALID_EVENT_SELECTION)
      end
    end

    it 'guests can equal the maximum allowed' do
      registration_request = FactoryBot.build(:registration_request, guests: 2)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))

      registration_result = RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request[:submitted_by])
      expect(registration_result).to eq(true)
    end

    it 'guests may equal 0' do
      registration_request = FactoryBot.build(:registration_request, guests: 0)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))

      registration_result = RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request[:submitted_by])
      expect(registration_result).to eq(true)
    end

    it 'guests cant exceed 0 if not allowed' do
      registration_request = FactoryBot.build(:registration_request, guests: 2)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition, guests_per_registration_limit: 0))

      expect {
        RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request[:submitted_by])
      }.to raise_error(RegistrationError) do |error|
        expect(error.http_status).to eq(:unprocessable_entity)
        expect(error.error).to eq(ErrorCodes::GUEST_LIMIT_EXCEEDED)
      end
    end

    it 'guests cannot exceed the maximum allowed' do
      registration_request = FactoryBot.build(:registration_request, guests: 3)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))

      expect {
        RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request[:submitted_by])
      }.to raise_error(RegistrationError) do |error|
        expect(error.http_status).to eq(:unprocessable_entity)
        expect(error.error).to eq(ErrorCodes::GUEST_LIMIT_EXCEEDED)
      end
    end

    it 'guests cannot be negative' do
      registration_request = FactoryBot.build(:registration_request, guests: -1)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))

      expect {
        RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request[:submitted_by])
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
        RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request[:submitted_by])
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

      expect(RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request[:submitted_by])).to eq(true)
    end

    it 'comment can be blank' do
      comment = ''
      registration_request = FactoryBot.build(:registration_request, :comment, raw_comment: comment)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition))

      expect(RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request[:submitted_by])).to eq(true)
    end

    it 'comment must be included if required' do
      registration_request = FactoryBot.build(:registration_request)
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition, force_comment_in_registration: true))

      expect {
        RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request[:submitted_by])
      }.to raise_error(RegistrationError) do |error|
        expect(error.http_status).to eq(:unprocessable_entity)
        expect(error.error).to eq(ErrorCodes::REQUIRED_COMMENT_MISSING)
      end
    end

    it 'comment cant be blank if required' do
      registration_request = FactoryBot.build(:registration_request, :comment, raw_comment: '')
      competition_info = CompetitionInfo.new(FactoryBot.build(:competition, force_comment_in_registration: true))

      expect {
        RegistrationChecker.create_registration_allowed!(registration_request, competition_info, registration_request[:submitted_by])
      }.to raise_error(RegistrationError) do |error|
        expect(error.http_status).to eq(:unprocessable_entity)
        expect(error.error).to eq(ErrorCodes::REQUIRED_COMMENT_MISSING)
      end
    end
  end
end
