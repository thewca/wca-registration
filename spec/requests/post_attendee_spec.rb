# frozen_string_literal: true

require 'swagger_helper'
require_relative '../support/registration_spec_helper'

# TODO: Check Swaggerized output
# TODO: Add test cases for various JWT token error codes
# TODO: Add test cases for competition API (new file)
# TODO: Add test cases for users API (new file)
# TODO: Add test cases for competition info being returned from endpoint (check that we respond appropriately to different values/conditionals)
# TODO: Validate expected vs actual output
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
        include_context 'basic_auth_token'
        include_context 'registration_data'
        include_context 'competition information'

        response '202', 'PASSING only required fields included' do
          let(:registration) { @required_fields_only }
          let(:'Authorization') { @jwt_token }

          run_test!
        end
      end
    end
  end
end
