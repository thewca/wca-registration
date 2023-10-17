# frozen_string_literal: true

require 'swagger_helper'
require_relative '../support/registration_spec_helper'
require_relative '../../app/helpers/competition_api'

# TODO: Figure out why RSwag isn't raising an error for the fact that we're getting a 200 not a 202 response
# TODO: create "smoke tests" that check the values written to the database - these should probably be request tests
# TODO: Reject a reg that tries to define lane state
# TODO: Submit registration that doesn't have all required fields
# TODO: Submits registration at guest limit (edge cases)
# TODO: Submits comment at character limit
# TODO: Submits comment over character limit
# TODO: Validate expected vs actual output
# TODO: Add test cases for various JWT token error codes
# TODO: Add test cases for competition API (new file)
# TODO: Add test cases for users API (new file)
# TODO: Add test cases for competition info being returned from endpoint (check that we respond appropriately to different values/conditionals)
# TODO: Check Swaggerized output
RSpec.describe 'v1 Registrations API', type: :request do
  include Helpers::RegistrationHelper

  path '/api/v1/register' do
    post 'Add an attendee registration' do
      security [Bearer: {}]
      consumes 'application/json'
      parameter name: :registration, in: :body,
                schema: { '$ref' => '#/components/schemas/submitRegistrationBody' }, required: true

      context '-> success registration posts' do
        # include_context 'database seed'
        # include_context 'auth_tokens'
        # include_context 'registration_data'
        # include_context 'competition information'

        response '202', '-> PASSING competitor submits basic registration' do
          before do
            competition = FactoryBot.build(:competition)
            stub_request(:get, comp_api_url(competition['competition_id'])).to_return(status: 200, body: competition.to_json)
          end

          registration = FactoryBot.build(:registration)
          let!(:registration) { registration }
          let(:Authorization) { registration[:jwt_token] }

          run_test! do |response|
            expect(response.body).to eq({ status: 'accepted', message: 'Started Registration Process' }.to_json)
          end
        end

        # This should be a controller test, or just a normal request test (might be good to have an integration test with mis-matching JWT/user_id)
        response '202', '-> PASSING admin registers before registration opens' do
          before do
            competition = FactoryBot.build(:competition, competition_opened?: false)
            stub_request(:get, comp_api_url(competition['competition_id'])).to_return(status: 200, body: competition.to_json)
          end

          registration = FactoryBot.build(:registration_for_admin)
          let(:registration) { registration }
          let(:Authorization) { registration[:jwt_token] }

          run_test!
        end

        # Failing: see above
        response '202', '-> PASSING admin submits registration for competitor' do
          before do
            competition = FactoryBot.build(:competition)
            stub_request(:get, comp_api_url(competition['competition_id'])).to_return(status: 200, body: competition.to_json)
          end

          registration = FactoryBot.build(:admin_submits_registration_for_user)
          let(:registration) { registration }
          let(:Authorization) { registration[:jwt_token] }

          run_test!
        end
      end

      # TODO: competitor does not meet qualification requirements - will need to mock users service for this? - investigate what the monolith currently does and replicate that
      context 'fail registration posts, from USER' do
        before do
          competition = FactoryBot.build(:competition)
          stub_request(:get, comp_api_url(competition['competition_id'])).to_return(status: 200, body: competition.to_json)
        end
        # include_context 'database seed'
        # include_context 'auth_tokens'
        # include_context 'registration_data'
        # include_context 'competition information'

        response '401', ' -> PASSING user impersonation (no admin permission, JWT token user_id does not match registration user_id)' do
          registration = FactoryBot.build(:impersonation)
          registration_error_json = { error: ErrorCodes::USER_INSUFFICIENT_PERMISSIONS }.to_json

          let(:registration) { registration }
          let(:Authorization) { registration[:jwt_token] }

          run_test! do |response|
            expect(response.body).to eq(registration_error_json)
          end
        end

        response '422', 'PASSING user registration exceeds guest limit' do
          registration = FactoryBot.build(:registration_with_guests, guests: 3)
          let(:registration) { registration }
          let(:Authorization) { registration[:jwt_token] }

          registration_error_json = { error: ErrorCodes::GUEST_LIMIT_EXCEEDED }.to_json

          run_test! do |response|
            expect(response.body).to eq(registration_error_json)
          end
        end

        response '403', ' -> PASSING user cant register while registration is closed' do
          before do
            competition = FactoryBot.build(:competition, registration_opened?: false)
            stub_request(:get, comp_api_url(competition['competition_id'])).to_return(status: 200, body: competition.to_json)
          end

          registration = FactoryBot.build(:registration)
          let(:registration) { registration }
          let(:Authorization) { registration[:jwt_token] }

          registration_error_json = { error: ErrorCodes::REGISTRATION_CLOSED }.to_json

          run_test! do |response|
            expect(response.body).to eq(registration_error_json)
          end
        end

        response '401', '-> PASSING attendee is banned' do
          registration = FactoryBot.build(:banned_competitor)
          let(:registration) { registration }
          let(:Authorization) { registration[:jwt_token] }

          registration_error_json = { error: ErrorCodes::USER_IS_BANNED }.to_json

          run_test! do |response|
            expect(response.body).to eq(registration_error_json)
          end
        end

        response '401', '-> PASSING competitor has incomplete profile' do
          registration = FactoryBot.build(:incomplete_profile)
          let(:registration) { registration }
          let(:Authorization) { registration[:jwt_token] }

          registration_error_json = { error: ErrorCodes::USER_PROFILE_INCOMPLETE }.to_json

          run_test! do |response|
            expect(response.body).to eq(registration_error_json)
          end
        end

        response '422', '-> PASSING contains event IDs which are not held at competition' do
          registration = FactoryBot.build(:registration, events: ['333', '333fm'])
          let(:registration) { registration }
          let(:Authorization) { registration[:jwt_token] }

          registration_error_json = { error: ErrorCodes::INVALID_EVENT_SELECTION }.to_json

          run_test! do |response|
            expect(response.body).to eq(registration_error_json)
          end
        end

        response '400', ' -> PASSING empty payload provided' do # getting a long error on this - not sure why it fails
          registration = FactoryBot.build(:registration)
          let(:registration) { {}.to_json }
          let(:Authorization) { registration[:jwt_token] }

          registration_error_json = { error: ErrorCodes::INVALID_REQUEST_DATA }.to_json

          run_test! do |response|
            expect(response.body).to eq(registration_error_json)
          end
        end

        response '404', ' -> PASSING competition does not exist' do
          before do
            wca_error_json = { error: 'Competition with id CompDoesntExist not found' }.to_json
            competition = FactoryBot.build(:competition, competition_id: 'CompDoesntExist')
            stub_request(:get, comp_api_url('CompDoesntExist')).to_return(status: 404, body: wca_error_json)
          end

          registration = FactoryBot.build(:registration, competition_id: 'CompDoesntExist')
          let(:registration) { registration }
          let(:Authorization) { registration[:jwt_token] }

          registration_error_json = { error: ErrorCodes::COMPETITION_NOT_FOUND }.to_json

          run_test! do |response|
            expect(response.body).to eq(registration_error_json)
          end
        end
      end

      context 'fail registration posts, from ADMIN' do
        # TODO: What is the difference between admin and organizer permissions? Should we add organizer test as well?
        # FAIL CASES TO IMPLEMENT:
        # convert all existing cases
        # user has insufficient permissions (admin of different comp trying to add reg)

        # include_context 'database seed'
        # include_context 'auth_tokens'
        # include_context 'registration_data'
        # include_context 'competition information'
        before do
          competition = FactoryBot.build(:competition)
          stub_request(:get, comp_api_url(competition['competition_id'])).to_return(status: 200, body: competition.to_json)
        end

        response '403', ' -> PASSING comp not open, admin adds another user' do
          before do
            competition = FactoryBot.build(:competition, registration_opened?: false)
            stub_request(:get, comp_api_url(competition['competition_id'])).to_return(status: 200, body: competition.to_json)
          end

          registration = FactoryBot.build(:admin_submits_registration_for_user)
          let(:registration) { registration }
          let(:Authorization) { registration[:jwt_token] }

          registration_error_json = { error: ErrorCodes::REGISTRATION_CLOSED }.to_json

          run_test! do |response|
            expect(response.body).to eq(registration_error_json)
          end
        end

        response '401', '-> PASSING admin adds banned user' do
          registration = FactoryBot.build(:admin_submits_registration_for_banned_user)
          let(:registration) { registration }
          let(:Authorization) { registration[:jwt_token] }

          registration_error_json = { error: ErrorCodes::USER_IS_BANNED }.to_json

          run_test! do |response|
            expect(response.body).to eq(registration_error_json)
          end
        end

        response '401', '-> PASSING admin adds competitor who has incomplete profile' do
          registration = FactoryBot.build(:admin_submits_registration_for_incomplete_user)
          let(:registration) { registration }
          let(:Authorization) { registration[:jwt_token] }

          registration_error_json = { error: ErrorCodes::USER_PROFILE_INCOMPLETE }.to_json

          run_test! do |response|
            expect(response.body).to eq(registration_error_json)
          end
        end

        response '422', '-> PASSING admins add other user reg which contains event IDs which are not held at competition' do
          registration = FactoryBot.build(:admin_submits_registration_for_user, events: ['333', '333fm'])
          let(:registration) { registration }
          let(:Authorization) { registration[:jwt_token] }

          registration_error_json = { error: ErrorCodes::INVALID_EVENT_SELECTION }.to_json

          run_test! do |response|
            expect(response.body).to eq(registration_error_json)
          end
        end

        response '422', '-> PASSING admin adds reg for user which contains event IDs which do not exist' do
          registration = FactoryBot.build(:admin_submits_registration_for_user, events: ['888'])
          let(:registration) { registration }
          let(:Authorization) { registration[:jwt_token] }

          registration_error_json = { error: ErrorCodes::INVALID_EVENT_SELECTION }.to_json

          run_test! do |response|
            expect(response.body).to eq(registration_error_json)
          end
        end

        response '400', ' -> PASSING admin adds registration with empty payload provided' do # getting a long error on this - not sure why it fails
          registration = FactoryBot.build(:admin_submits_registration_for_user)
          let(:registration) { {}.to_json }
          let(:Authorization) { registration[:jwt_token] }

          registration_error_json = { error: ErrorCodes::INVALID_REQUEST_DATA }.to_json

          run_test! do |response|
            expect(response.body).to eq(registration_error_json)
          end
        end

        response '404', ' -> PASSING admin adds reg for competition which does not exist' do
          before do
            wca_error_json = { error: 'Competition with id CompDoesntExist not found' }.to_json
            competition = FactoryBot.build(:competition, competition_id: 'CompDoesntExist')
            stub_request(:get, comp_api_url('CompDoesntExist')).to_return(status: 404, body: wca_error_json)
          end

          registration = FactoryBot.build(:admin_submits_registration_for_user, competition_id: 'CompDoesntExist')
          let(:registration) { registration }
          let(:Authorization) { registration[:jwt_token] }

          registration_error_json = { error: ErrorCodes::COMPETITION_NOT_FOUND }.to_json

          run_test! do |response|
            expect(response.body).to eq(registration_error_json)
          end
        end
      end
    end
  end
end
