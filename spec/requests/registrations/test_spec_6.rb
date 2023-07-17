# frozen_string_literal: true

require 'swagger_helper'
require_relative '../../support/helpers/registration_spec_helper'

RSpec.shared_examples 'payload test' do |payload|
  include Helpers::RegistrationHelper

  before do
    puts "Payload: #{payload}"
  end

  let(:registration) { payload }
  let(:'Authorization') { @jwt_token } # Hardcoding the JWT token will lead to an impersonation error on the 2nd test if we send it the correct payload
  run_test!
end

RSpec.describe 'v1 Registrations API', type: :request do
  include Helpers::RegistrationHelper
  include_context 'basic_auth_token'
  include_context 'registration_fixtures'

  path '/api/v1/register' do
    post 'Add an attendee registration' do
      consumes 'application/json'
      parameter name: 'Authorization', in: :header, type: :string
      parameter name: :registration, in: :body,
                schema: { '$ref' => '#/components/schemas/registration' }, required: true

      response '202', 'various optional fields' do
        # before do
        #   puts "Test reg: #{@test_registration}"
        # end
        #
        @test_registration = {
          user_id:"158817", 
          competition_id:"CubingZANationalChampionship2023",
          competing: {
            event_ids:["333", "333MBF"]
          }
        }

        let(:registration) { @test_registration }
        let(:'Authorization') { @jwt_token } # Hardcoding the JWT token will lead to an impersonation error on the 2nd test if we send it the correct payload
        run_test!
      end


        # it_behaves_like 'payload test', @test_registration
    end
  end
end
