require 'swagger_helper'
require_relative '../support/helpers/registration_spec_helper'

# TODO: Create shared contexts to share webmock stubs between success and fail cases
# TODO: Write more tests for other cases according to airtable

RSpec.describe 'v1 Registrations API', type: :request do
  include Helpers::Registration

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

        # TODO: Need to write shared contexts to implement
        # response '200', 'Competitions Service is down but we have registrations for the competition_id in our database' do
        #   let!(:competition_id) { competition_with_registrations }

        #   error_json = { error:
        #     'Internal Server Error for url: /api/v0/competitions/CubingZANationalChampionship2023' }.to_json


        #   stub_request(:get, "https://www.worldcubeassociation.org/api/v0/competitions/#{competition_id}")
        #     .to_return(status: 500, body: error_json)

        #   # TODO: Validate the expected list of registrations
        #   run_test!
        # end


        # TODO: Define a registration payload we expect to receive - wait for ORM to be implemented to achieve this.
        # response '200' 'Validate that registration details received match expected details' do
        # end 

        # TODO: define access scopes in order to implement run this tests
        # response '200', 'User is allowed to access registration data (various scenarios)' do
        #   let!(:competition_id) { competition_id }
        # end
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

        context 'competition service not available - 500' do
          before do
            error_json = { error:
              'Internal Server Error for url: /api/v0/competitions/CubingZANationalChampionship2023' }.to_json

            stub_request(:get, "https://www.worldcubeassociation.org/api/v0/competitions/#{competition_id}")
              .to_return(status: 500, body: error_json)
          end

          response '500', 'Competition service unavailable - 500 error' do
            let!(:competition_id) { competition_with_registrations }

            run_test! do |response|
              expect(response.body).to eq({ error: 'Could not No response received from WCA Competition Service.'})
          end
        end

        context 'competition service not available - 502' do
          before do
            error_json =  { error:
              'Internal Server Error for url: /api/v0/competitions/CubingZANationalChampionship2023' }.to_json

            stub_request(:get, "https://www.worldcubeassociation.org/api/v0/competitions/#{competition_id}")
              .to_return(status: 502, body: error_json)
          end

          response '502', 'Competition service unavailable - 502 error' do
            let!(:competition_id) { competition_with_registrations }

            run_test!
          end
        end

        # TODO: define access scopes in order to implement run this tests
        # response '403', 'User is not allowed to access registration data (various scenarios)' do
        # end
      end
    end

    post 'Create registrations in bulk' do
      # TODO: Figure out tests for bulk registration creation endpoint
      # NOTE: This is not currently part of our features
    end
  end

  path '/api/v1/registration/{attendee_id}' do
    get 'Retrieve attendee registration' do
      parameter name: :attendee_id, in: :path, type: :string, required: true
      produces 'application/json'

      context 'success get attendee registration' do
        existing_attendee = 'CubingZANationalChampionship2023-158816'

        response '200', 'validate endpoint and schema' do
          schema '$ref' => '#/components/schemas/registration'

          let!(:attendee_id) { existing_attendee }

          run_test!
        end

        response '200', 'check that registration returned matches expected registration' do
          let!(:attendee_id) { existing_attendee }

          expected_registration = get_registration(existing_attendee)

          run_test! do |response|
            expect(response.body).to eq(expected_registration)
          end
        end
      end

      context 'fail get attendee registration' do
        response '404', 'attendee_id doesnt exist' do
          let!(:attendee_id) { 'InvalidAttendeeID' }

          run_test! do |response|
            expect(response.body).to eq({ error: "No registration found for attendee_id: #{attendee_id}." }.to_json)
          end
        end
      end
    end
  end
end
