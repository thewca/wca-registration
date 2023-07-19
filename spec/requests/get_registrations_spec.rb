# frozen_string_literal: true

require 'swagger_helper'
require_relative '../support/registration_spec_helper'
require_relative '../../app/helpers/error_codes'

RSpec.describe 'v1 Registrations API', type: :request do
  include Helpers::RegistrationHelper

  path '/api/v1/registrations/{competition_id}' do
    get 'List registrations for a given competition_id' do
      parameter name: :competition_id, in: :path, type: :string, required: true
      produces 'application/json'

      # TODO: Check the list contents against expected list contents
      context 'success responses' do
        include_context 'competition information'
        include_context 'database seed'

        response '200', 'request and response conform to schema' do
          schema type: :array, items: { '$ref' => '#/components/schemas/registration' }

          let!(:competition_id) { @comp_with_registrations }

          run_test!
        end

        response '200', 'Valid competition_id but no registrations for it' do
          let!(:competition_id) { @empty_comp }

          run_test! do |response|
            body = JSON.parse(response.body)
            expect(body).to eq([])
          end
        end

        # TODO
        # context 'Competition service down (500) but registrations exist' do
        #   response '200', 'comp service down but registrations exist' do
        #     let!(:competition_id) { competition_with_registrations }

        #     run_test!
        #   end
        # end

        # TODO: This test is malformed - it isn't testing what it is trying to
        # context 'Competition service down (502) but registrations exist' do
        # include_context '502 response from competition service'

        # response '200', 'Competitions Service is down but we have registrations for the competition_id in our database' do
        # let!(:competition_id) { competition_with_registrations }

        # TODO: Validate the expected list of registrations
        # run_test!
        # end
        # end

        # TODO: Define a registration payload we expect to receive - wait for ORM to be implemented to achieve this.
        # response '200', 'Validate that registration details received match expected details' do
        # end

        # TODO: define access scopes in order to implement run this tests
        response '200', 'User is allowed to access registration data (various scenarios)' do
          let!(:competition_id) { competition_id }
        end
      end

      context 'fail responses' do
        include_context 'competition information'
        context 'competition_id not found by Competition Service' do
          registration_error_json = { error: ErrorCodes::COMPETITION_NOT_FOUND }.to_json

          response '404', 'Competition ID doesnt exist' do
            schema '$ref' => '#/components/schemas/error_response'
            let(:competition_id) { @error_comp_404 }

            run_test! do |response|
              expect(response.body).to eq(registration_error_json)
            end
          end
        end

        context '500 - competition service not available (500) and no registrations in our database for competition_id' do
          registration_error_json = { error: ErrorCodes::COMPETITION_API_5XX }.to_json
          response '500', 'Competition service unavailable - 500 error' do
            schema '$ref' => '#/components/schemas/error_response'
            let!(:competition_id) { @error_comp_500 }

            run_test! do |response|
              expect(response.body).to eq(registration_error_json)
            end
          end
        end

        context '502 - competition service not available - 502, and no registration for competition ID' do
          registration_error_json = { error: ErrorCodes::COMPETITION_API_5XX }.to_json
          response '502', 'Competition service unavailable - 502 error' do
            schema '$ref' => '#/components/schemas/error_response'
            let!(:competition_id) { @error_comp_502 }

            run_test! do |response|
              expect(response.body).to eq(registration_error_json)
            end
          end
        end

        # TODO: define access scopes in order to implement run this tests
        # response '403', 'User is not allowed to access registration data (various scenarios)' do
        # end
      end
    end
  end
end
