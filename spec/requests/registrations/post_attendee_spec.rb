# frozen_string_literal: true

require 'swagger_helper'
require_relative '../../support/helpers/registration_spec_helper'

RSpec.describe 'v1 Registrations API', type: :request do
  include Helpers::RegistrationHelper

  path '/api/v1/register' do
    post 'Add an attendee registration' do
      consumes 'application/json'
      parameter name: :registration, in: :body,
                schema: { '$ref' => '#/components/schemas/submitRegistrationBody' }, required: true
      parameter name: 'Authorization', in: :header, type: :string
      produces 'application/json'
      registration_success_json = { status: 'accepted', message: 'Started Registration Process' }.to_json
      missing_token_json = { error: -2000 }.to_json

      context 'success registration posts' do
        include_context 'database seed'
        include_context 'basic_auth_token'
        include_context 'registration_data'
        include_context 'stub ZA champs comp info'

        response '202', 'only required fields included' do
          schema '$ref' => '#/components/schemas/success_response'
          let(:registration) { @required_fields_only }
          let(:Authorization) { @jwt_token }

          run_test! do |response|
            expect(response.body).to eq(registration_success_json)
          end
        end
        response '403', 'user impersonation attempt' do
          schema '$ref' => '#/components/schemas/error_response'
          let(:registration) { @required_fields_only }
          let(:Authorization) { @jwt_token_wrong_user }
          run_test! do |response|
            expect(response.body).to eq(missing_token_json)
          end
        end
      end
    end
  end
end
