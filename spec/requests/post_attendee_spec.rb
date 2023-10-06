# frozen_string_literal: true

require 'swagger_helper'
require_relative '../support/registration_spec_helper'

# TODO: Submits registration at guest limit
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
        include_context 'competition information'

        # Failing: due to "Cannot do operations on a non-existent table" error - Finn input needed, I've done a basic check
        response '202', '-> FAILING admin registers before registration opens' do
          registration = FactoryBot.build(:admin, events: ["444", "333bf"], competition_id: "BrizZonSylwesterOpen2023")
          let(:registration) { registration }
          let(:Authorization) { registration[:jwt_token] }

          run_test! do |response|
            assert_requested :get, "#{@base_comp_url}#{@registrations_not_open}", times: 1
          end
        end

        # Failing: see above
        response '202', '-> FAILING competitor submits basic registration' do
          registration = FactoryBot.build(:registration)
          let!(:registration) { registration }
          let(:Authorization) { registration[:jwt_token] }

          run_test! do |response|
            assert_requested :get, "#{@base_comp_url}#{@includes_non_attending_registrations}", times: 1
          end
        end

        # Failing: see above
        response '202', '-> FAILING admin submits registration for competitor' do
          registration = FactoryBot.build(:admin_submits)
          let(:registration) { registration }
          let(:Authorization) { registration[:jwt_token] }

          run_test! do |response|
            assert_requested :get, "#{@base_comp_url}#{@includes_non_attending_registrations}", times: 1
          end
        end
      end

      # TODO: competitor does not meet qualification requirements - will need to mock users service for this? - investigate what the monolith currently does and replicate that
      context 'fail registration posts, from USER' do
        include_context 'database seed'
        include_context 'auth_tokens'
        include_context 'registration_data'
        include_context 'competition information'

        response '401', ' -> PASSING user impersonation (no admin permission, JWT token user_id does not match registration user_id)' do
          registration_error_json = { error: ErrorCodes::USER_IMPERSONATION }.to_json
          let(:registration) { @required_fields_only }
          let(:Authorization) { @jwt_200 }
          run_test! do |response|
            expect(response.body).to eq(registration_error_json)
          end
        end

        response '422', 'PASSING user registration exceeds guest limit' do
          registration_error_json = { error: ErrorCodes::GUEST_LIMIT_EXCEEDED }.to_json
          let(:registration) { @too_many_guests }
          let(:Authorization) { @jwt_824 }

          run_test! do |response|
            expect(response.body).to eq(registration_error_json)
          end
        end

        response '403', ' -> PASSING user cant register while registration is closed' do
          registration_error_json = { error: ErrorCodes::REGISTRATION_CLOSED }.to_json
          let(:registration) { @comp_not_open }
          let(:Authorization) { @jwt_817 }
          run_test! do |response|
            expect(response.body).to eq(registration_error_json)
          end
        end

        response '401', '-> PASSING attendee is banned' do
          registration_error_json = { error: ErrorCodes::USER_IS_BANNED }.to_json
          let(:registration) { @banned_user_reg }
          let(:Authorization) { @banned_user_jwt }

          run_test! do |response|
            expect(response.body).to eq(registration_error_json)
          end
        end

        response '401', '-> PASSING competitor has incomplete profile' do
          registration_error_json = { error: ErrorCodes::USER_PROFILE_INCOMPLETE }.to_json
          let(:registration) { @incomplete_user_reg }
          let(:Authorization) { @incomplete_user_jwt }

          run_test! do |response|
            expect(response.body).to eq(registration_error_json)
          end
        end

        response '422', '-> PASSING contains event IDs which are not held at competition' do
          registration_error_json = { error: ErrorCodes::INVALID_EVENT_SELECTION }.to_json
          let(:registration) { @events_not_held_reg }
          let(:Authorization) { @jwt_201 }

          run_test! do |response|
            expect(response.body).to eq(registration_error_json)
          end
        end

        response '422', '-> PASSING contains event IDs which are not held at competition' do
          registration_error_json = { error: ErrorCodes::INVALID_EVENT_SELECTION }.to_json
          let(:registration) { @events_not_exist_reg }
          let(:Authorization) { @jwt_202 }

          run_test! do |response|
            expect(response.body).to eq(registration_error_json)
          end
        end

        response '400', ' -> PASSING empty payload provided' do # getting a long error on this - not sure why it fails
          let(:registration) { @empty_payload }
          let(:Authorization) { @jwt_817 }

          run_test!
        end

        response '404', ' -> PASSING competition does not exist' do
          registration_error_json = { error: ErrorCodes::COMPETITION_NOT_FOUND }.to_json
          let(:registration) { @bad_comp_name }
          let(:Authorization) { @jwt_817 }

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

        include_context 'database seed'
        include_context 'auth_tokens'
        include_context 'registration_data'
        include_context 'competition information'

        response '202', '-> FAILING admin organizer for wrong competition submits registration for competitor' do
          let(:registration) { @reg_2 }
          let(:Authorization) { @organizer_token }

          run_test!
        end

        response '403', ' -> PASSING comp not open, admin adds another user' do
          registration_error_json = { error: ErrorCodes::REGISTRATION_CLOSED }.to_json
          let(:registration) { @comp_not_open }
          let(:Authorization) { @admin_token }
          run_test! do |response|
            expect(response.body).to eq(registration_error_json)
          end
        end

        response '401', '-> PASSING admin adds banned user' do
          registration_error_json = { error: ErrorCodes::USER_IS_BANNED }.to_json
          let(:registration) { @banned_user_reg }
          let(:Authorization) { @admin_token }

          run_test! do |response|
            expect(response.body).to eq(registration_error_json)
          end
        end

        response '401', '-> PASSING admin adds competitor who has incomplete profile' do
          registration_error_json = { error: ErrorCodes::USER_PROFILE_INCOMPLETE }.to_json
          let(:registration) { @incomplete_user_reg }
          let(:Authorization) { @admin_token }

          run_test! do |response|
            expect(response.body).to eq(registration_error_json)
          end
        end

        response '422', '-> PASSING admins add other user reg which contains event IDs which are not held at competition' do
          registration_error_json = { error: ErrorCodes::INVALID_EVENT_SELECTION }.to_json
          let(:registration) { @events_not_held_reg }
          let(:Authorization) { @admin_token }

          run_test! do |response|
            expect(response.body).to eq(registration_error_json)
          end
        end

        response '422', '-> PASSING admin adds reg for user which contains event IDs which do not exist' do
          registration_error_json = { error: ErrorCodes::INVALID_EVENT_SELECTION }.to_json
          let(:registration) { @events_not_exist_reg }
          let(:Authorization) { @jwt_202 }

          run_test! do |response|
            expect(response.body).to eq(registration_error_json)
          end
        end

        response '400', ' -> PASSING admin adds registration with empty payload provided' do # getting a long error on this - not sure why it fails
          let(:registration) { @empty_payload }
          let(:Authorization) { @admin_token }

          run_test!
        end

        response '404', ' -> PASSING admin adds reg for competition which does not exist' do
          registration_error_json = { error: ErrorCodes::COMPETITION_NOT_FOUND }.to_json
          let(:registration) { @bad_comp_name }
          let(:Authorization) { @jwt_817 }

          run_test! do |response|
            expect(response.body).to eq(registration_error_json)
          end
        end
      end
    end
  end
end
