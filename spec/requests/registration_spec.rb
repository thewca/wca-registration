require 'swagger_helper'
require_relative '../support/helpers/registration_spec_helper'

# TODO: Edit path to include URL in path intead of added as a parameter
# TODO: Figure out how to run only tests with certain tags?
# TODO: Get tests working (currently having an issue with competition_id in stub)
# TODO: Move "get_competition_details" to a separate file
# TODO: Once I'm happy with this test file, get it working using the docker-compose.test.yml file
# TODO: Write more tests for other cases according to airtable
# TODO: Refactor schema from GET registrations into the GET registration and add a ref to the singular schema in GET registrations

RSpec.describe 'v1 Registrations API', type: :request do

  # TODO: Move this out to a helper file
  def get_competition_details competition_id
    # Open the json file called 'competition_details.json'
    File.open("#{Rails.root}/spec/fixtures/competition_details.json", 'r') do |f|
      competition_details = JSON.parse(f.read)

      # Retrieve the competition details
      competition_details['competitions'].each do |competition|
        return competition.to_json if competition['id'] == competition_id
      end
    end
  end

  path '/api/v1/registrations' do # This could also be /api/v1/registrations/{competition_id}?
    get 'List registrations for a given competition_id' do
      parameter name: :competition_id, in: :query, type: :string, required: true
      produces 'application/json'

      context 'success responses' do
        competition_with_registrations = 'CubingZANationalChampionship2023'
        competition_no_attendees = '1AVG2013'

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
        competition_with_registrations = 'CubingZANationalChampionship2023'

        response '400', 'Competition ID not provided' do
          let!(:competition_id) { nil }

          run_test! do |response|
            body = JSON.parse(response.body)
            expect(body).to eq({ "error": 'Competition ID not provided' })
          end
        end

        response '404', 'Comeptition ID doesnt exist' do
          let!(:competition_id) { 'InvalidCompID' }

          # Convert has to json
          error_json = { 'error': 'Competition with id InvalidCompId not found' }.to_json

          stub_request(:get, "https://www.worldcubeassociation.org/api/v0/competitions/#{competition_id}")
            .to_return(status: 404, body: error_json)

          run_test! do |response|
            body = JSON.parse(response.body)
            expect(body).to eq(error_json)
          end
        end

        response '500', 'Competition service unavailable - 500 error' do
          let!(:competition_id) { competition_with_registrations }

          stub_request(:get, "https://www.worldcubeassociation.org/api/v0/competitions/#{competition_id}")
            .to_return(status: 500, body: { error:
              'Internal Server Error for url: /api/v0/competitions/CubingZANationalChampionship2023' })

          run_test!
        end

        response '502', 'Competition service unavailable - 502 error' do
          let!(:competition_id) { competition_with_registrations }

          stub_request(:get, "https://www.worldcubeassociation.org/api/v0/competitions/#{competition_id}")
            .to_return(status: 502, body: { error:
              'Internal Server Error for url: /api/v0/competitions/CubingZANationalChampionship2023' })

          run_test!
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
