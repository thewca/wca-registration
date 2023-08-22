# frozen_string_literal: true

require 'swagger_helper'
require_relative '../support/registration_spec_helper'

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
        # SUCCESS CASES TO IMPLEMENT
        # admin submits registration on competitor's behalf
        include_context 'database seed'
        include_context 'auth_tokens'
        include_context 'registration_data'
        include_context 'competition information'

        response '202', '-> PASSING competitor submits basic registration' do
          let(:registration) { @required_fields_only }
          let(:Authorization) { @jwt_817 }

          run_test! do |response|
            assert_requested :get, "#{@base_comp_url}#{@includes_non_attending_registrations}", times: 1
          end
        end

        response '202', '-> PASSING admin registers before registration opens' do
          let(:registration) { @admin_comp_not_open }
          let(:Authorization) { @admin_token_2 }

          run_test! do |response|
            assert_requested :get, "#{@base_comp_url}#{@registrations_not_open}", times: 1
          end
        end

        response '202', '-> PASSING admin submits registration for competitor' do
          let(:registration) { @required_fields_only }
          let(:Authorization) { @admin_token }

          run_test! do |response|
            assert_requested :get, "#{@base_comp_url}#{@includes_non_attending_registrations}", times: 1
          end
        end
      end

      context 'fail registration posts, from USER' do
        # FAIL CASES TO IMPLEMENT:
        # competitor does not meet qualification requirements - will need to mock users service for this? - investigate what the monolith currently does and replicate that

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


        response '403', ' -> PASSING comp not open' do
          registration_error_json = { error: ErrorCodes::COMPETITION_CLOSED }.to_json
          let(:registration) { @comp_not_open }
          let(:Authorization) { @jwt_817 }
          run_test! do |response|
            expect(response.body).to eq(registration_error_json)
          end
        end

        response '403', '-> PASSING attendee is banned' do
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
          registration_error_json = { error: ErrorCodes::COMPETITION_INVALID_EVENTS }.to_json
          let(:registration) { @events_not_held_reg }
          let(:Authorization) { @jwt_201 }

          run_test! do |response|
            expect(response.body).to eq(registration_error_json)
          end
        end

        response '422', '-> PASSING contains event IDs which are not held at competition' do
          registration_error_json = { error: ErrorCodes::COMPETITION_INVALID_EVENTS }.to_json
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

        response '202', '-> admin FAILING organizer for wrong competition submits registration for competitor' do
          let(:registration) { @reg_2 }
          let(:Authorization) { @organizer_token }

          run_test!
        end

        response '403', ' -> PASSING comp not open, admin adds another user' do
          registration_error_json = { error: ErrorCodes::COMPETITION_CLOSED }.to_json
          let(:registration) { @comp_not_open }
          let(:Authorization) { @admin_token }
          run_test! do |response|
            expect(response.body).to eq(registration_error_json)
          end
        end

        response '403', '-> PASSING admin adds banned user' do
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
          registration_error_json = { error: ErrorCodes::COMPETITION_INVALID_EVENTS }.to_json
          let(:registration) { @events_not_held_reg }
          let(:Authorization) { @admin_token }

          run_test! do |response|
            expect(response.body).to eq(registration_error_json)
          end
        end

        response '422', '-> PASSING admin adds reg for user which contains event IDs which do not exist' do
          registration_error_json = { error: ErrorCodes::COMPETITION_INVALID_EVENTS }.to_json
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
