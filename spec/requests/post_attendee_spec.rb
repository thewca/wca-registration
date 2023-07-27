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
        include_context 'database seed'
        include_context 'auth_tokens'
        include_context 'registration_data'
        include_context 'competition information'

        response '202', 'PASSING only required fields included' do
          let(:registration) { @required_fields_only }
          let(:'Authorization') { @jwt_token }
          run_test!
        end
      end

      context 'fail registration posts' do
        # FAIL CASES TO IMPLEMENT:
        # comp not open
        # JWT token doesn't match user id (user impersonation)
        # no payload provided
        # empty payload provided
        # competition not found
        # cutoff not met
        # user is banned
        # user has incomplete profile
        # user has insufficient permissions (admin trying to add someone else's reg) - we might need to add a new type of auth for this?

        include_context 'database seed'
        include_context 'auth_tokens'
        include_context 'registration_data'
        include_context 'competition information'

        response '400', 'FAILING comp not open' do
          let(:registration) { @comp_not_open }
          let(:'Authorization') { @jwt_token }
          run_test!
        end

        response '200', 'FAILING empty payload provided' do # getting a long error on this - not sure why it fails
          let(:registration) { @empty_payload }
          let(:'Authorization') { @jwt_token }

          run_test!
        end
      end
    end
  end
end
