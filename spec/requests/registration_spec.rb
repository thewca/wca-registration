require 'swagger_helper'
require_relative '../support/helpers/registration_spec_helper'

# TODO: Once I'm happy with this test file, get it working using the docker-compose.test.yml file

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

  path '/registrations' do # This could also be /api/v1/registrations/{competition_id}?
    get 'List registrations for a given competition_id' do
      parameter name: :competition_id, in: :query, type: :string, required: true
      produces 'application/json'

      context 'success responses' do
        competition_id = 'CubingZANationalChampionship2023'

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

          let!(:competition_id) { competition_id }

          run_test!
          # TODO: Validate that the response returns the expected data - may not be needed after spec is added
        end

        # response '200', 'User is allowed to access registration data (various scenarios)' do
        # end

        # response '200', 'Valid competition_id but no registrations for it' do
        # end
      end

      # response '400', 'Competition ID parameter mis-spelled' do
      # end

      # response '400', 'Competition ID not provided' do
      # end

      # response '401', 'Tampered JWT token rejected' do
      # end

      # response '404', 'Comeptition ID doesnt exist' do
      # end

      # response '403', 'User is not allowed to access registration data (various scenarios)' do
      # end

      # response '502', 'Competition service unavailable' do
      # end
    end
  end
end
