require 'swagger_helper'
require_relative '../support/helpers/registration_spec_helper'

# TODO: Once I'm happy with this test file, get it working using the docker-compose.test.yml file
# TODO: Write more tests for other cases according to airtable
# TODO: Refactor schema from GET registrations into the GET registration and add a ref to the singular schema in GET registrations

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
          schema type: :array,
            items: {
              type: :object,
                properties: {
                  attendee_id: { type: :string },
                  competition_id: { type: :string },
                  user_id: { type: :string },
                  is_attending: { type: :boolean },
                  lane_states: {
                    type: :object
                  },
                  lanes: {
                    type: :array,
                    items: {
                      type: :object,
                      properties: {
                        lane_name: { type: :string },
                        lane_state: { type: :string },
                        completed_steps: {
                          type: :array
                        },
                        lane_details: {
                          type: :object
                        },
                        payment_reference: { type: :string },
                        payment_amount: { type: :string },
                        transaction_currency: { type: :string },
                        discount_percentage: { type: :string },
                        discount_amount: { type: :string },
                        last_action: { type: :string },
                        last_action_datetime: { type: :string, format: :date_time },
                        last_action_user: { type: :string }
                      },
                      required: [:lane_name, :lane_state, :completed_steps, :lane_details,
                                 :payment_reference, :payment_amount, :transaction_currency,
                                 :last_action, :last_action_datetime, :last_action_user]
                    }
                  },
                  hide_name_publicly: { type: :boolean }
                },
              required: [:attendee_id, :competition_id, :user_id, :is_attending, :lane_states,
                         :lanes, :hide_name_publicly]
            }

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

        # TODO: define access scopes in order to implement run this tests
        # response '200', 'User is allowed to access registration data (various scenarios)' do
        #   let!(:competition_id) { competition_id }

        # end
      end

      context 'fail responses' do
        response '400', 'Competition ID not provided' do
          let!(:competition_id) { nil }

          run_test! do |response|
            body = JSON.parse(response.body)
            expect(body).to eq({ "error": 'Competition ID not provided' })
          end
        end

        context 'competition id not found by Competition Service' do
          before do
            error_json = { error: 'Competition with id InvalidCompId not found' }.to_json

            stub_request(:get, "https://www.worldcubeassociation.org/api/v0/competitions/#{competition_id}")
              .to_return(status: 404, body: error_json)
          end

          response '404', 'Comeptition ID doesnt exist' do
            let!(:competition_id) { 'InvalidCompID' }

            run_test! do |response|
              body = JSON.parse(response.body)
              expect(body).to eq(error_json)
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

            run_test!
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
end
