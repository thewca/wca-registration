# frozen_string_literal: true

require 'swagger_helper'
require_relative '../../support/helpers/registration_spec_helper'

RSpec.describe 'v1 Registrations API', type: :request do
  include Helpers::RegistrationHelper

  path '/api/v1/registrations/{competition_id}' do
    get 'List registrations for a given competition_id' do
      parameter name: :competition_id, in: :path, type: :string, required: true
      produces 'application/json'

      competition_with_registrations = 'CubingZANationalChampionship2023'
      competition_no_attendees = '1AVG2013'

      context 'success responses' do
        before do
          competition_details = get_competition_details(competition_id)

          # Stub the request to the Competition Service
          stub_request(:get, "https://www.worldcubeassociation.org/api/v0/competitions/#{competition_id}")
            .to_return(status: 200, body: competition_details)
        end

        response '200', 'request and response conform to schema' do
          schema type: :array, items: { '$ref' => '#/components/schemas/registration' }

          let!(:competition_id) { competition_with_registrations }

          run_test!
        end

        response '200', 'Valid competition_id but no registrations for it' do
          let!(:competition_id) { competition_no_attendees }

          run_test! do |response|
            body = JSON.parse(response.body)
            expect(body).to eq([])
          end
        end

        # TODO: Refactor these to use shared examples once they are passing
        context 'Competition service down (500) but registrations exist' do
          include_context '500 response from competition service'

          response '200', 'comp service down but registrations exist' do
            let!(:competition_id) { competition_with_registrations }

            # TODO: Validate the expected list of registrations
            run_test!
          end
        end

        context 'Competition service down (502) but registrations exist' do
          include_context '502 response from competition service'

          response '200', 'Competitions Service is down but we have registrations for the competition_id in our database' do
            let!(:competition_id) { competition_with_registrations }

            # TODO: Validate the expected list of registrations
            run_test!
          end
        end

        # TODO: Define a registration payload we expect to receive - wait for ORM to be implemented to achieve this.
        # response '200', 'Validate that registration details received match expected details' do
        # end

        # TODO: define access scopes in order to implement run this tests
        response '200', 'User is allowed to access registration data (various scenarios)' do
          let!(:competition_id) { competition_id }
        end
      end

      context 'fail responses' do
        response '400', 'Competition ID not provided' do
          let!(:competition_id) { nil }

          run_test! do |response|
            expect(response.body).to eq({ error: 'Competition ID not provided' }.to_json)
          end
        end

        context 'competition_id not found by Competition Service' do
          before do
            error_json = { error: 'Competition with id InvalidCompId not found' }.to_json

            stub_request(:get, "https://www.worldcubeassociation.org/api/v0/competitions/#{competition_id}")
              .to_return(status: 404, body: error_json)
          end

          response '404', 'Comeptition ID doesnt exist' do
            let!(:competition_id) { 'InvalidCompID' }

            run_test! do |response|
              expect(response.body).to eq(error_json)
            end
          end
        end

        # TODO: Refactor to use shared_examples once passing
        context 'competition service not available (500) and no registrations in our database for competition_id' do
          include_context '500 response from competition service'

          response '500', 'Competition service unavailable - 500 error' do
            let!(:competition_id) { competition_no_attendees }

            run_test! do |response|
              expect(response.body).to eq({ error: 'No registrations found - could not reach Competition Service to confirm competition_id validity.' }.to_json)
            end
          end
        end

        # TODO: Refactor to use shared_examples once passing
        context 'competition service not available - 502' do
          include_context '502 response from competition service'

          response '502', 'Competition service unavailable - 502 error' do
            let!(:competition_id) { competition_no_attendees }

            run_test! do |response|
              expect(response.body).to eq({ error: 'No registrations found - could not reach Competition Service to confirm competition_id validity.' }.to_json)
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
