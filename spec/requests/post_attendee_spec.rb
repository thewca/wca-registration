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
                schema: { '$ref' => '#/components/schemas/registration' }, required: true

      context 'success registration posts' do
        # SUCCESS CASES TO IMPLEMENT
        # admin submits registration on competitor's behalf
        include_context 'database seed'
        include_context 'auth_tokens'
        include_context 'registration_data'
        include_context 'competition information'

        response '202', 'PASSING only required fields included' do
          let(:registration) { @required_fields_only }
          let(:Authorization) { @jwt_token }
          # run_test!
          before do |example|
            submit_request(example.metadata)
          end

          it 'tests the 202 response' do |example|
            assert_requested :get, "#{@base_comp_url}#{@includes_non_attending_registrations}", times: 1
          end
        end
      end

      context 'fail registration posts' do
        # FAIL CASES TO IMPLEMENT:
        # x comp not open
        # x JWT token doesn't match user id (user impersonation)
        # x no payload provided
        # competition not found
        # competitor does not meet qualification requirements - will need to mock users service for this? - investigate what the monolith currently does and replicate that
        # user is banned
        # user has incomplete profile
        # submit events taht don't exist at the comp
        # user has insufficient permissions (admin of different comp trying to add reg)

        include_context 'database seed'
        include_context 'auth_tokens'
        include_context 'registration_data'
        include_context 'competition information'

        response '401', 'PASSING user impersonation (no admin permission, JWWT token user_id does not match registration user_id)' do
          registration_error_json = { error: ErrorCodes::USER_IMPERSONATION }.to_json
          let(:registration) { @required_fields_only }
          let(:Authorization) { @user_2 }
          run_test! do |response|
            expect(response.body).to eq(registration_error_json)
          end
        end

        response '403', 'PASSING comp not open' do
          registration_error_json = { error: ErrorCodes::COMPETITION_CLOSED }.to_json
          let(:registration) { @comp_not_open }
          let(:Authorization) { @jwt_token }
          run_test! do |response|
            expect(response.body).to eq(registration_error_json)
          end
        end

        response '400', 'PASSING empty payload provided' do # getting a long error on this - not sure why it fails
          let(:registration) { @empty_payload }
          let(:Authorization) { @jwt_token }

          run_test!
        end
      end
    end
  end
end
