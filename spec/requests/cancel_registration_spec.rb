# frozen_string_literal: true

require 'swagger_helper'
require_relative '../../app/helpers/error_codes'

RSpec.describe 'v1 Registrations API', type: :request do
  include Helpers::RegistrationHelper

  path '/api/v1/register' do
    patch 'update or cancel an attendee registration' do
      security [Bearer: {}]
      consumes 'application/json'
      parameter name: :registration_update, in: :body,
                schema: { '$ref' => '#/components/schemas/updateRegistrationBody' }, required: true

      produces 'application/json'

      context 'SUCCESS: user registration cancellations' do
        before do
          competition = FactoryBot.build(:competition)
          stub_request(:get, comp_api_url(competition['competition_id'])).to_return(status: 200, body: competition.to_json)
          cancellation = FactoryBot.build(:update_payload, update_details: { 'status' => 'cancelled' })
        end


        response '200', 'PASSING cancel accepted registration' do
          before do
            registration = FactoryBot.create(:registration)
          end
          cancellation = FactoryBot.build(:update_payload, update_details: { 'status' => 'cancelled' })
          let(:registration_update) { cancellation }
          let(:Authorization) { cancellation[:jwt_token] }

          run_test! do |response|
            # Make sure body contains the values we expect
            body = JSON.parse(response.body)
            response_data = body['registration']

            updated_registration = Registration.find("#{registration_update[:competition_id]}-#{registration_update[:user_id]}")
            puts updated_registration.inspect

            expect(response_data['registration_status']).to eq('cancelled')

            # Make sure the registration stored in the dabatase contains teh values we expect
            expect(updated_registration.registered_event_ids).to eq([])
            expect(updated_registration.competing_status).to eq('cancelled')
          end
        end

        response '200', 'PASSING cancel accepted registration, event statuses change to "cancelled"' do
          cancellation = FactoryBot.build(:update_payload, update_details: { 'status' => 'cancelled' })
          let(:registration_update) { cancellation }
          let(:Authorization) { cancellation[:jwt_token] }

          run_test! do |response|
            # Make sure body contains the values we expect
            body = JSON.parse(response.body)
            body['registration']

            updated_registration = Registration.find("#{registration_update[:competition_id]}-#{registration_update[:user_id]}")
            puts updated_registration.inspect
            updated_registration.event_details.each do |event|
              expect(event['event_registration_state']).to eq('cancelled')
            end
          end
        end

        response '200', 'PASSING cancel pending registration' do
          before { registration = FactoryBot.create(:registration, lane_state: 'pending') }

          cancellation = FactoryBot.build(:update_payload, update_details: { 'status' => 'cancelled' })
          let(:registration_update) { cancellation }
          let(:Authorization) { cancellation[:jwt_token] }

          run_test! do |response|
            # Make sure body contains the values we expect
            body = JSON.parse(response.body)
            response_data = body['registration']
            puts "response_data: #{response_data}"

            updated_registration = Registration.find("#{registration_update[:competition_id]}-#{registration_update[:user_id]}")
            puts updated_registration.inspect

            expect(response_data['registered_event_ids']).to eq([])
            expect(response_data['registration_status']).to eq('cancelled')

            # Make sure the registration stored in the dabatase contains teh values we expect
            expect(updated_registration.registered_event_ids).to eq([])
            expect(updated_registration.competing_status).to eq('cancelled')
          end
        end

        response '200', 'PASSING cancel update_pending registration' do
          before { registration = FactoryBot.create(:registration, lane_state: 'update_pending') }

          cancellation = FactoryBot.build(:update_payload, update_details: { 'status' => 'cancelled' })
          let(:registration_update) { cancellation }
          let(:Authorization) { cancellation[:jwt_token] }

          run_test! do |response|
            # Make sure body contains the values we expect
            body = JSON.parse(response.body)
            response_data = body['registration']
            puts "response_data: #{response_data}"

            updated_registration = Registration.find("#{registration_update[:competition_id]}-#{registration_update[:user_id]}")
            puts updated_registration.inspect

            expect(response_data['registered_event_ids']).to eq([])
            expect(response_data['registration_status']).to eq('cancelled')

            # Make sure the registration stored in the dabatase contains teh values we expect
            expect(updated_registration.registered_event_ids).to eq([])
            expect(updated_registration.competing_status).to eq('cancelled')
          end
        end

        response '200', 'PASSING cancel waiting_list registration' do
          before { registration = FactoryBot.create(:registration, lane_state: 'waiting_list') }

          cancellation = FactoryBot.build(:update_payload, update_details: { 'status' => 'cancelled' })
          let(:registration_update) { cancellation }
          let(:Authorization) { cancellation[:jwt_token] }

          run_test! do |response|
            # Make sure body contains the values we expect
            body = JSON.parse(response.body)
            response_data = body['registration']
            puts "response_data: #{response_data}"

            updated_registration = Registration.find("#{registration_update[:competition_id]}-#{registration_update[:user_id]}")
            puts updated_registration.inspect

            expect(response_data['registered_event_ids']).to eq([])
            expect(response_data['registration_status']).to eq('cancelled')

            # Make sure the registration stored in the dabatase contains teh values we expect
            expect(updated_registration.registered_event_ids).to eq([])
            expect(updated_registration.competing_status).to eq('cancelled')
          end
        end

        response '200', 'PASSING cancel cancelled registration' do
          before { registration = FactoryBot.create(:registration, lane_state: 'cancelled') }

          cancellation = FactoryBot.build(:update_payload, update_details: { 'status' => 'cancelled' })
          let(:registration_update) { cancellation }
          let(:Authorization) { cancellation[:jwt_token] }

          run_test! do |response|
            # Make sure body contains the values we expect
            body = JSON.parse(response.body)
            response_data = body['registration']
            puts "response_data: #{response_data}"

            updated_registration = Registration.find("#{registration_update[:competition_id]}-#{registration_update[:user_id]}")
            puts updated_registration.inspect

            expect(response_data['registered_event_ids']).to eq([])
            expect(response_data['registration_status']).to eq('cancelled')

            # Make sure the registration stored in the dabatase contains teh values we expect
            expect(updated_registration.registered_event_ids).to eq([])
            expect(updated_registration.competing_status).to eq('cancelled')
          end
        end
      end

      context 'SUCCESS: admin registration cancellations' do
        before do
          competition = FactoryBot.build(:competition)
          stub_request(:get, comp_api_url(competition['competition_id'])).to_return(status: 200, body: competition.to_json)
          cancellation = FactoryBot.build(:update_payload, update_details: { 'status' => 'cancelled' })
        end

        response '200', 'PASSING admin cancels their own registration' do
          before { registration = FactoryBot.create(:registration, :admin) }

          cancellation = FactoryBot.build(:update_payload, :admin_as_user, update_details: { 'status' => 'cancelled' })
          let(:registration_update) { cancellation }
          let(:Authorization) { cancellation[:jwt_token] }

          run_test! do |response|
            # Make sure body contains the values we expect
            body = JSON.parse(response.body)
            response_data = body['registration']
            puts "response_data: #{response_data}"

            updated_registration = Registration.find("#{registration_update[:competition_id]}-#{registration_update[:user_id]}")
            puts updated_registration.inspect

            expect(response_data['registered_event_ids']).to eq([])
            expect(response_data['registration_status']).to eq('cancelled')

            # Make sure the registration stored in the dabatase contains teh values we expect
            expect(updated_registration.registered_event_ids).to eq([])
            expect(updated_registration.competing_status).to eq('cancelled')
          end
        end

        response '200', 'PASSING admin cancel accepted registration' do
          before { registration = FactoryBot.create(:registration) }

          cancellation = FactoryBot.build(:update_payload, :admin_for_user, update_details: { 'status' => 'cancelled' })
          let(:registration_update) { cancellation }
          let(:Authorization) { cancellation[:jwt_token] }

          run_test! do |response|
            # Make sure body contains the values we expect
            body = JSON.parse(response.body)
            response_data = body['registration']
            puts "response_data: #{response_data}"

            updated_registration = Registration.find("#{registration_update[:competition_id]}-#{registration_update[:user_id]}")
            puts updated_registration.inspect

            expect(response_data['registered_event_ids']).to eq([])
            expect(response_data['registration_status']).to eq('cancelled')

            # Make sure the registration stored in the dabatase contains teh values we expect
            expect(updated_registration.registered_event_ids).to eq([])
            expect(updated_registration.competing_status).to eq('cancelled')
          end
        end

        response '200', 'PASSING admin cancel accepted registration with admin comment' do
          admin_comment = 'this is a test comment'
          before { registration = FactoryBot.create(:registration) }

          cancellation = FactoryBot.build(:update_payload, :admin_for_user, update_details: { 
                                                                                            'status' => 'cancelled', 'admin_comment' => admin_comment })
          let(:registration_update) { cancellation }
          let(:Authorization) { cancellation[:jwt_token] }

          run_test! do |response|
            # Make sure body contains the values we expect
            body = JSON.parse(response.body)
            response_data = body['registration']
            puts "response_data: #{response_data}"

            updated_registration = Registration.find("#{registration_update[:competition_id]}-#{registration_update[:user_id]}")
            puts updated_registration.inspect

            expect(response_data['registered_event_ids']).to eq([])
            expect(response_data['registration_status']).to eq('cancelled')

            # Make sure the registration stored in the dabatase contains teh values we expect
            expect(updated_registration.registered_event_ids).to eq([])
            expect(updated_registration.competing_status).to eq('cancelled')

            expect(updated_registration.admin_comment).to eq(admin_comment)
          end
        end

        response '200', 'PASSING admin cancel pending registration' do
          before { registration = FactoryBot.create(:registration, lane_state: 'pending') }

          cancellation = FactoryBot.build(:update_payload, :admin_for_user, update_details: { 'status' => 'cancelled' })
          let(:registration_update) { cancellation }
          let(:Authorization) { cancellation[:jwt_token] }

          run_test! do |response|
            # Make sure body contains the values we expect
            body = JSON.parse(response.body)
            response_data = body['registration']
            puts "response_data: #{response_data}"

            updated_registration = Registration.find("#{registration_update[:competition_id]}-#{registration_update[:user_id]}")
            puts updated_registration.inspect

            expect(response_data['registered_event_ids']).to eq([])
            expect(response_data['registration_status']).to eq('cancelled')

            # Make sure the registration stored in the dabatase contains teh values we expect
            expect(updated_registration.registered_event_ids).to eq([])
            expect(updated_registration.competing_status).to eq('cancelled')
          end
        end

        response '200', 'PASSING admin cancel update_pending registration' do
          before { registration = FactoryBot.create(:registration, lane_state: 'update_pending') }

          cancellation = FactoryBot.build(:update_payload, :admin_for_user, update_details: { 'status' => 'cancelled' })
          let(:registration_update) { cancellation }
          let(:Authorization) { cancellation[:jwt_token] }

          run_test! do |response|
            # Make sure body contains the values we expect
            body = JSON.parse(response.body)
            response_data = body['registration']
            puts "response_data: #{response_data}"

            updated_registration = Registration.find("#{registration_update[:competition_id]}-#{registration_update[:user_id]}")
            puts updated_registration.inspect

            expect(response_data['registered_event_ids']).to eq([])
            expect(response_data['registration_status']).to eq('cancelled')

            # Make sure the registration stored in the dabatase contains teh values we expect
            expect(updated_registration.registered_event_ids).to eq([])
            expect(updated_registration.competing_status).to eq('cancelled')
          end
        end

        response '200', 'PASSING admin cancel waiting_list registration' do
          before { registration = FactoryBot.create(:registration, lane_state: 'waiting_list') }

          cancellation = FactoryBot.build(:update_payload, :admin_for_user, update_details: { 'status' => 'cancelled' })
          let(:registration_update) { cancellation }
          let(:Authorization) { cancellation[:jwt_token] }

          run_test! do |response|
            # Make sure body contains the values we expect
            body = JSON.parse(response.body)
            response_data = body['registration']
            puts "response_data: #{response_data}"

            updated_registration = Registration.find("#{registration_update[:competition_id]}-#{registration_update[:user_id]}")
            puts updated_registration.inspect

            expect(response_data['registered_event_ids']).to eq([])
            expect(response_data['registration_status']).to eq('cancelled')

            # Make sure the registration stored in the dabatase contains teh values we expect
            expect(updated_registration.registered_event_ids).to eq([])
            expect(updated_registration.competing_status).to eq('cancelled')
          end
        end

        response '200', 'PASSING admin cancel cancelled registration' do
          before { registration = FactoryBot.create(:registration, lane_state: 'cancelled') }

          cancellation = FactoryBot.build(:update_payload, :admin_for_user, update_details: { 'status' => 'cancelled' })
          let(:registration_update) { cancellation }
          let(:Authorization) { cancellation[:jwt_token] }

          run_test! do |response|
            # Make sure body contains the values we expect
            body = JSON.parse(response.body)
            response_data = body['registration']
            puts "response_data: #{response_data}"

            updated_registration = Registration.find("#{registration_update[:competition_id]}-#{registration_update[:user_id]}")
            puts updated_registration.inspect

            expect(response_data['registered_event_ids']).to eq([])
            expect(response_data['registration_status']).to eq('cancelled')

            # Make sure the registration stored in the dabatase contains teh values we expect
            expect(updated_registration.registered_event_ids).to eq([])
            expect(updated_registration.competing_status).to eq('cancelled')
          end
        end

        response '200', 'PASSING organizer cancels their own registration' do
          before { registration = FactoryBot.create(:registration, :organizer) }

          cancellation = FactoryBot.build(:update_payload, :organizer_for_self, update_details: { 'status' => 'cancelled' })
          let(:registration_update) { cancellation }
          let(:Authorization) { cancellation[:jwt_token] }

          run_test! do |response|
            # Make sure body contains the values we expect
            body = JSON.parse(response.body)
            response_data = body['registration']
            puts "response_data: #{response_data}"

            updated_registration = Registration.find("#{registration_update[:competition_id]}-#{registration_update[:user_id]}")
            puts updated_registration.inspect

            expect(response_data['registered_event_ids']).to eq([])
            expect(response_data['registration_status']).to eq('cancelled')

            # Make sure the registration stored in the dabatase contains teh values we expect
            expect(updated_registration.registered_event_ids).to eq([])
            expect(updated_registration.competing_status).to eq('cancelled')
          end
        end

        response '200', 'PASSING organizer cancel accepted registration' do
          before { registration = FactoryBot.create(:registration) }

          cancellation = FactoryBot.build(:update_payload, :organizer_for_user, update_details: { 'status' => 'cancelled' })
          let(:registration_update) { cancellation }
          let(:Authorization) { cancellation[:jwt_token] }

          run_test! do |response|
            # Make sure body contains the values we expect
            body = JSON.parse(response.body)
            response_data = body['registration']
            puts "response_data: #{response_data}"

            updated_registration = Registration.find("#{registration_update[:competition_id]}-#{registration_update[:user_id]}")
            puts updated_registration.inspect

            expect(response_data['registered_event_ids']).to eq([])
            expect(response_data['registration_status']).to eq('cancelled')

            # Make sure the registration stored in the dabatase contains teh values we expect
            expect(updated_registration.registered_event_ids).to eq([])
            expect(updated_registration.competing_status).to eq('cancelled')
          end
        end

        response '200', 'PASSING organizer cancel accepted registration with comment' do
          admin_comment = 'this is a test comment'
          before { registration = FactoryBot.create(:registration) }

          cancellation = FactoryBot.build(:update_payload, :organizer_for_user, update_details: { 
                                                                                            'status' => 'cancelled', 'admin_comment' => admin_comment })
          let(:registration_update) { cancellation }
          let(:Authorization) { cancellation[:jwt_token] }

          run_test! do |response|
            # Make sure body contains the values we expect
            body = JSON.parse(response.body)
            response_data = body['registration']
            puts "response_data: #{response_data}"

            updated_registration = Registration.find("#{registration_update[:competition_id]}-#{registration_update[:user_id]}")
            puts updated_registration.inspect

            expect(response_data['registered_event_ids']).to eq([])
            expect(response_data['registration_status']).to eq('cancelled')

            # Make sure the registration stored in the dabatase contains teh values we expect
            expect(updated_registration.registered_event_ids).to eq([])
            expect(updated_registration.competing_status).to eq('cancelled')

            expect(updated_registration.admin_comment).to eq(admin_comment)
          end
        end

        response '200', 'PASSING organizer cancel pending registration' do
          before { registration = FactoryBot.create(:registration, lane_state: 'pending') }

          cancellation = FactoryBot.build(:update_payload, :organizer_for_user, update_details: { 'status' => 'cancelled' })
          let(:registration_update) { cancellation }
          let(:Authorization) { cancellation[:jwt_token] }

          run_test! do |response|
            # Make sure body contains the values we expect
            body = JSON.parse(response.body)
            response_data = body['registration']
            puts "response_data: #{response_data}"

            updated_registration = Registration.find("#{registration_update[:competition_id]}-#{registration_update[:user_id]}")
            puts updated_registration.inspect

            expect(response_data['registered_event_ids']).to eq([])
            expect(response_data['registration_status']).to eq('cancelled')

            # Make sure the registration stored in the dabatase contains teh values we expect
            expect(updated_registration.registered_event_ids).to eq([])
            expect(updated_registration.competing_status).to eq('cancelled')
          end
        end

        response '200', 'PASSING organizer cancel update_pending registration' do
          before { registration = FactoryBot.create(:registration, lane_state: 'update_pending') }

          cancellation = FactoryBot.build(:update_payload, :organizer_for_user, update_details: { 'status' => 'cancelled' })
          let(:registration_update) { cancellation }
          let(:Authorization) { cancellation[:jwt_token] }

          run_test! do |response|
            # Make sure body contains the values we expect
            body = JSON.parse(response.body)
            response_data = body['registration']
            puts "response_data: #{response_data}"

            updated_registration = Registration.find("#{registration_update[:competition_id]}-#{registration_update[:user_id]}")
            puts updated_registration.inspect

            expect(response_data['registered_event_ids']).to eq([])
            expect(response_data['registration_status']).to eq('cancelled')

            # Make sure the registration stored in the dabatase contains teh values we expect
            expect(updated_registration.registered_event_ids).to eq([])
            expect(updated_registration.competing_status).to eq('cancelled')
          end
        end

        response '200', 'PASSING organizer cancel waiting_list registration' do
          before { registration = FactoryBot.create(:registration, lane_state: 'waiting_list') }

          cancellation = FactoryBot.build(:update_payload, :organizer_for_user, update_details: { 'status' => 'cancelled' })
          let(:registration_update) { cancellation }
          let(:Authorization) { cancellation[:jwt_token] }

          run_test! do |response|
            # Make sure body contains the values we expect
            body = JSON.parse(response.body)
            response_data = body['registration']
            puts "response_data: #{response_data}"

            updated_registration = Registration.find("#{registration_update[:competition_id]}-#{registration_update[:user_id]}")
            puts updated_registration.inspect

            expect(response_data['registered_event_ids']).to eq([])
            expect(response_data['registration_status']).to eq('cancelled')

            # Make sure the registration stored in the dabatase contains teh values we expect
            expect(updated_registration.registered_event_ids).to eq([])
            expect(updated_registration.competing_status).to eq('cancelled')
          end
        end

        response '200', 'PASSING organizer cancel cancelled registration' do
          before { registration = FactoryBot.create(:registration, lane_state: 'cancelled') }

          cancellation = FactoryBot.build(:update_payload, :organizer_for_user, update_details: { 'status' => 'cancelled' })
          let(:registration_update) { cancellation }
          let(:Authorization) { cancellation[:jwt_token] }

          run_test! do |response|
            # Make sure body contains the values we expect
            body = JSON.parse(response.body)
            response_data = body['registration']
            puts "response_data: #{response_data}"

            updated_registration = Registration.find("#{registration_update[:competition_id]}-#{registration_update[:user_id]}")
            puts updated_registration.inspect

            expect(response_data['registered_event_ids']).to eq([])
            expect(response_data['registration_status']).to eq('cancelled')

            # Make sure the registration stored in the dabatase contains teh values we expect
            expect(updated_registration.registered_event_ids).to eq([])
            expect(updated_registration.competing_status).to eq('cancelled')
          end
        end
      end

      context 'FAIL: registration cancellations' do
        before do
          competition = FactoryBot.build(:competition)
          stub_request(:get, comp_api_url(competition['competition_id'])).to_return(status: 200, body: competition.to_json)
        end

        response '401', 'PASSING user tries to submit an admin payload' do
          before { registration = FactoryBot.create(:registration) }

          admin_comment = 'test admin comment'
          cancellation = FactoryBot.build(:update_payload, update_details: { 'status' => 'cancelled', 'admin_comment' => admin_comment })
          let(:registration_update) { cancellation }
          let(:Authorization) { cancellation[:jwt_token] }

          error_response = { error: ErrorCodes::USER_INSUFFICIENT_PERMISSIONS }.to_json

          run_test! do |response|
            expect(response.body).to eq(error_response)
          end
        end

        response '401', 'PASSING admin submits cancellation for a comp they arent an admin for' do
          before do
            competition = FactoryBot.build(:competition, competition_id: 'FinnishChampionship2023')
            stub_request(:get, comp_api_url(competition['competition_id'])).to_return(status: 200, body: competition.to_json)
            registration = FactoryBot.create(:registration, competition_id: 'FinnishChampionship2023') 
          end

          cancellation = FactoryBot.build(:update_payload, :organizer_for_user, competition_id: 'FinnishChampionship2023', update_details: { 'status' => 'cancelled' })
          let(:registration_update) { cancellation }
          let(:Authorization) { cancellation[:jwt_token] }

          error_response = { error: ErrorCodes::USER_INSUFFICIENT_PERMISSIONS }.to_json

          run_test! do |response|
            expect(response.body).to eq(error_response)
          end
        end

        response '401', 'PASSING user submits a cancellation for a different user' do
          before { registration = FactoryBot.create(:registration) }

          cancellation = FactoryBot.build(:update_payload, :for_another_user, update_details: { 'status' => 'cancelled'})
          let(:registration_update) { cancellation }
          let(:Authorization) { cancellation[:jwt_token] }

          error_response = { error: ErrorCodes::USER_INSUFFICIENT_PERMISSIONS }.to_json

          run_test! do |response|
            expect(response.body).to eq(error_response)
          end
        end

        response '404', 'PASSING cancel on competition that doesnt exist' do
          before do
            wca_error_json = { error: 'Competition with id CompDoesntExist not found' }.to_json
            competition = FactoryBot.build(:competition, competition_id: 'CompDoesntExist')
            stub_request(:get, comp_api_url('CompDoesntExist')).to_return(status: 404, body: wca_error_json)
            registration = FactoryBot.create(:registration, competition_id: 'BadCompName') 
          end

          cancellation = FactoryBot.build(:update_payload, competition_id: 'CompDoesntExist', update_details: { 'status' => 'cancelled'})
          let(:registration_update) { cancellation }
          let(:Authorization) { cancellation[:jwt_token] }

          registration_error_json = { error: ErrorCodes::COMPETITION_NOT_FOUND }.to_json

          run_test! do |reponse|
            expect(response.body).to eq(registration_error_json)
          end
        end

        response '404', 'PASSING cancel on competitor ID that isnt registered' do
          cancellation = FactoryBot.build(:update_payload, update_details: { 'status' => 'cancelled'})
          let(:registration_update) { cancellation }
          let(:Authorization) { cancellation[:jwt_token] }

          registration_error_json = { error: ErrorCodes::REGISTRATION_NOT_FOUND }.to_json

          run_test! do |reponse|
            expect(response.body).to eq(registration_error_json)
          end
        end

        response '422', 'PASSING reject cancel with changed event ids' do
          before { registration = FactoryBot.create(:registration) }

          cancellation = FactoryBot.build(:update_payload, update_details: { 'status' => 'cancelled', 'event_ids' => ['444', '555'] })
          let(:registration_update) { cancellation }
          let(:Authorization) { cancellation[:jwt_token] }

          registration_error_json = { error: ErrorCodes::INVALID_EVENT_SELECTION }.to_json

          # Use separate before/it so that we can read the old event IDs before Registration object is updated
          before do |example|
            @old_event_ids = Registration.find("#{registration_update[:competition_id]}-#{registration_update[:user_id]}").event_ids
            @response = submit_request(example.metadata)
          end

          it 'returns a 422' do |example|
            # run_test! do |response|
            body = JSON.parse(response.body)
            body['registration']

            updated_registration = Registration.find("#{registration_update[:competition_id]}-#{registration_update[:user_id]}")

            # Make sure that event_ids from old and update registration match
            expect(updated_registration.event_ids).to eq(@old_event_ids)
            assert_response_matches_metadata(example.metadata)
            expect(response.body).to eq(registration_error_json)
          end
        end
      end

      # context 'SUCCESS: registration updates' do
      # end
    end
  end
end
