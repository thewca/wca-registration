# frozen_string_literal: true

require 'swagger_helper'
require_relative '../support/registration_spec_helper'

RSpec.describe 'v1 Registrations API', type: :request do
  include Helpers::RegistrationHelper

  path '/api/v1/register' do
    post 'Add an attendee registration' do
      consumes 'application/json'
      parameter name: :registration, in: :body,
                schema: { '$ref' => '#/components/schemas/registration' }, required: true
      parameter name: 'Authorization', in: :header, type: :string

      context 'success registration posts' do
        include_context 'database seed'
        include_context 'basic_auth_token'
        include_context 'registration_data'
        include_context 'stub ZA champs comp info'

        response '202', 'only required fields included' do
          let(:registration) { @required_fields_only }
          let(:Authorization) { @jwt_token }

          run_test!
        end
      end
    end
  end
end
