require 'swagger_helper'
require_relative '../support/helpers/registration_spec_helper'

# TODO: Write more tests for other cases according to airtable

# TODO: See if shared contexts can be put into a helper file once tests are passing
# TODO: Refactor these into a shared example once they are passing
RSpec.shared_context 'Registrations' do
  before do
    basic_registration = get_registration('CubingZANationalChampionship2023-158816')
    required_fields_only = get_registration('CubingZANationalChampionship2023-158817')
    missing_reg_fields = get_registration('')
    no_attendee_id = get_registration('CubingZANationalChampionship2023-158818')
  end
end

RSpec.shared_context '500 response from competition service' do
  before do
    error_json = { error:
      'Internal Server Error for url: /api/v0/competitions/CubingZANationalChampionship2023' }.to_json

    stub_request(:get, "https://www.worldcubeassociation.org/api/v0/competitions/#{competition_id}")
      .to_return(status: 500, body: error_json)
  end
end

RSpec.shared_context '502 response from competition service' do
  before do
    error_json =  { error: 'Internal Server Error for url: /api/v0/competitions/CubingZANationalChampionship2023' }.to_json

    stub_request(:get, "https://www.worldcubeassociation.org/api/v0/competitions/#{competition_id}")
      .to_return(status: 502, body: error_json)
  end
end

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

  #       # TODO: Refactor to use shared_examples once passing
        context 'competition service not available - 502' do
          include_context '502 response from competition service'

          response '502', 'Competition service unavailable - 502 error' do
            let!(:competition_id) { competition_no_attendees }

            run_test! do |response|
              expect(response.body).to eq({ error: 'No registrations found - could not reach Competition Service to confirm competition_id validity.' }.to_json)
            end
          end
        end

  #       # TODO: define access scopes in order to implement run this tests
        response '403', 'User is not allowed to access registration data (various scenarios)' do
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
          include_context 'Registrations' 

          let!(:attendee_id) { existing_attendee }

          run_test! do |response|
            expect(response.body).to eq(basic_registration)
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

  # TODO: POST registration tests
  # TODO: Validate the different lanes against their schemas
  # TODO: Figure out how to validate that webhook responses are receive? (that might be an integration/end-to-end test)

  path '/api/v1/registration' do
    post 'Add an attendee registration' do
      parameter name: :registration, in: :body,
                schema: { '$ref' => '#/components/schemas/registration' }, required: true

      # TODO: Figure out how to validate the data written to the database
      context 'success registration posts' do
        response '202', 'validate schema and response' do
          include_context 'Registrations'
          let(:registration) { basic_registration }

          run_test!
        end

        response '202', 'only required fields included' do
          include_context 'Registrations'
          let(:registration) { required_fields_only }
          
          run_test!
        end
      end

      context 'fail: request validation fails' do
        response 'fail', 'empty json provided' do
          before do
            registration = {}
          end
            
          let!(:registration) { registration }

          run_test!
        end

        # TODO: Figure out how to parametrize this using shared contexts/examples once it is passing
        response 'fail', 'not all required fields included' do
          include_context 'Registrations'
          
          let!(:registration) { no_attendee_id }

          run_test!
        end

        response 'fail', 'spelling error on field name' do
        # TODO: write
        end

        response 'fail' 'non-permitted fields included' do
        # TODO: write
        end
      end

      context 'fail: general elibigibility validation fails' do
        response 'fail' 'attendee is banned as a competitor' do
          # TODO: write
          # NOTE: We need to figure out what the scope of bans are - do they prevent a user from registering at all, or only certain lanes?
          # Have contacted WDC to confirm
        end

        request 'fail' 'attendee has incomplete profile' do
          # TODO: write
        end

      end

      context 'fail: competition elibigibility validation fails' do
          # pass
        
        request 'fail' 'user does not pass qualification' do
          # TODO: write
        end

        request 'fail' 'overall attendee limit reached' do
          # TODO: write
          # NOTE: This would be a combination of the currently accepted attendees, those on the waiting list, and those pending
          # NOTE: There are actually a few ways to implement this that we need to think through
        end
      end
    end
  end
end


# TODO: Add tests for competition_id, user_id and validity of attendee_id
