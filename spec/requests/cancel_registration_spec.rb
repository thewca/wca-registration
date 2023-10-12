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
        # Events can't be updated when cancelling registration
        # Refactor the registration status checks into a seaprate functionN? (not sure if this is possible but worth a try)
        # # test removing events (I guess this is an udpate?)
        # Other fields get left alone when cancelling registration
        include_context 'competition information'
        include_context 'PATCH payloads'
        include_context 'database seed'
        include_context 'auth_tokens'

        response '200', 'PASSING cancel accepted registration' do
          let(:registration_update) { @cancellation_816 }
          let(:Authorization) { @jwt_816 }

          run_test! do |response|
            # Make sure body contains the values we expect
            body = JSON.parse(response.body)
            response_data = body["registration"]
            puts "response_data: #{response_data}"

            updated_registration = Registration.find("#{registration_update['competition_id']}-#{registration_update['user_id']}")
            puts updated_registration.inspect

            expect(response_data["registration_status"]).to eq("cancelled")

            # Make sure the registration stored in the dabatase contains teh values we expect
            expect(updated_registration.registered_event_ids).to eq([])
            expect(updated_registration.competing_status).to eq("cancelled")
          end
        end

        response '200', 'PASSING cancel accepted registration, event statuses change to "cancelled"' do
          let(:registration_update) { @cancellation_816 }
          let(:Authorization) { @jwt_816 }

          run_test! do |response|
            # Make sure body contains the values we expect
            body = JSON.parse(response.body)
            body["registration"]

            updated_registration = Registration.find("#{registration_update['competition_id']}-#{registration_update['user_id']}")
            puts updated_registration.inspect
            updated_registration.event_details.each do |event|
              expect(event["event_registration_state"]).to eq("cancelled")
            end
          end
        end

        response '200', 'PASSING cancel pending registration' do
          # This method is not asynchronous so we're looking for a 200
          let(:registration_update) { @cancellation_817 }
          let(:Authorization) { @jwt_817 }

          run_test! do |response|
            # Make sure body contains the values we expect
            body = JSON.parse(response.body)
            response_data = body["registration"]
            puts "response_data: #{response_data}"

            updated_registration = Registration.find("#{registration_update['competition_id']}-#{registration_update['user_id']}")
            puts updated_registration.inspect

            expect(response_data["registered_event_ids"]).to eq([])
            expect(response_data["registration_status"]).to eq("cancelled")

            # Make sure the registration stored in the dabatase contains teh values we expect
            expect(updated_registration.registered_event_ids).to eq([])
            expect(updated_registration.competing_status).to eq("cancelled")
          end
        end

        response '200', 'PASSING cancel update_pending registration' do
          # This method is not asynchronous so we're looking for a 200
          let(:registration_update) { @cancellation_818 }
          let(:Authorization) { @jwt_818 }

          run_test! do |response|
            # Make sure body contains the values we expect
            body = JSON.parse(response.body)
            response_data = body["registration"]
            puts "response_data: #{response_data}"

            updated_registration = Registration.find("#{registration_update['competition_id']}-#{registration_update['user_id']}")
            puts updated_registration.inspect

            expect(response_data["registered_event_ids"]).to eq([])
            expect(response_data["registration_status"]).to eq("cancelled")

            # Make sure the registration stored in the dabatase contains teh values we expect
            expect(updated_registration.registered_event_ids).to eq([])
            expect(updated_registration.competing_status).to eq("cancelled")
          end
        end

        response '200', 'PASSING cancel waiting_list registration' do
          # This method is not asynchronous so we're looking for a 200
          let(:registration_update) { @cancellation_819 }
          let(:Authorization) { @jwt_819 }

          run_test! do |response|
            # Make sure body contains the values we expect
            body = JSON.parse(response.body)
            response_data = body["registration"]
            puts "response_data: #{response_data}"

            updated_registration = Registration.find("#{registration_update['competition_id']}-#{registration_update['user_id']}")
            puts updated_registration.inspect

            expect(response_data["registered_event_ids"]).to eq([])
            expect(response_data["registration_status"]).to eq("cancelled")

            # Make sure the registration stored in the dabatase contains teh values we expect
            expect(updated_registration.registered_event_ids).to eq([])
            expect(updated_registration.competing_status).to eq("cancelled")
          end
        end

        response '200', 'PASSING cancel cancelled registration' do
          # This method is not asynchronous so we're looking for a 200
          let(:registration_update) { @cancellation_823 }
          let(:Authorization) { @jwt_823 }

          run_test! do |response|
            # Make sure body contains the values we expect
            body = JSON.parse(response.body)
            response_data = body["registration"]
            puts "response_data: #{response_data}"

            updated_registration = Registration.find("#{registration_update['competition_id']}-#{registration_update['user_id']}")
            puts updated_registration.inspect

            expect(response_data["registered_event_ids"]).to eq([])
            expect(response_data["registration_status"]).to eq("cancelled")

            # Make sure the registration stored in the dabatase contains teh values we expect
            expect(updated_registration.registered_event_ids).to eq([])
            expect(updated_registration.competing_status).to eq("cancelled")
          end
        end
      end

      context 'SUCCESS: admin registration cancellations' do
        include_context 'PATCH payloads'
        include_context 'competition information'
        include_context 'database seed'
        include_context 'auth_tokens'

        response '200', 'PASSING admin cancels their own registration' do
          # This method is not asynchronous so we're looking for a 200
          let(:registration_update) { @cancellation_073 }
          let(:Authorization) { @admin_token }

          run_test! do |response|
            # Make sure body contains the values we expect
            body = JSON.parse(response.body)
            response_data = body["registration"]
            puts "response_data: #{response_data}"

            updated_registration = Registration.find("#{registration_update['competition_id']}-#{registration_update['user_id']}")
            puts updated_registration.inspect

            expect(response_data["registered_event_ids"]).to eq([])
            expect(response_data["registration_status"]).to eq("cancelled")

            # Make sure the registration stored in the dabatase contains teh values we expect
            expect(updated_registration.registered_event_ids).to eq([])
            expect(updated_registration.competing_status).to eq("cancelled")
          end
        end

        response '200', 'PASSING admin cancel accepted registration' do
          # This method is not asynchronous so we're looking for a 200
          let(:registration_update) { @cancellation_816 }
          let(:Authorization) { @admin_token }

          run_test! do |response|
            # Make sure body contains the values we expect
            body = JSON.parse(response.body)
            response_data = body["registration"]
            puts "response_data: #{response_data}"

            updated_registration = Registration.find("#{registration_update['competition_id']}-#{registration_update['user_id']}")
            puts updated_registration.inspect

            expect(response_data["registered_event_ids"]).to eq([])
            expect(response_data["registration_status"]).to eq("cancelled")

            # Make sure the registration stored in the dabatase contains teh values we expect
            expect(updated_registration.registered_event_ids).to eq([])
            expect(updated_registration.competing_status).to eq("cancelled")
          end
        end

        response '200', 'PASSING admin cancel accepted registration with comment' do
          # This method is not asynchronous so we're looking for a 200
          let(:registration_update) { @cancellation_816_2 }
          let(:Authorization) { @admin_token }

          run_test! do |response|
            # Make sure body contains the values we expect
            body = JSON.parse(response.body)
            response_data = body["registration"]
            puts "response_data: #{response_data}"

            updated_registration = Registration.find("#{registration_update['competition_id']}-#{registration_update['user_id']}")
            puts updated_registration.inspect

            expect(response_data["registered_event_ids"]).to eq([])
            expect(response_data["registration_status"]).to eq("cancelled")

            # Make sure the registration stored in the dabatase contains teh values we expect
            expect(updated_registration.registered_event_ids).to eq([])
            expect(updated_registration.competing_status).to eq("cancelled")

            expect(updated_registration.admin_comment).to eq(registration_update["competing"]["admin_comment"])
          end
        end

        response '200', 'PASSING admin cancel pending registration' do
          # This method is not asynchronous so we're looking for a 200
          let(:registration_update) { @cancellation_817 }
          let(:Authorization) { @admin_token }

          run_test! do |response|
            # Make sure body contains the values we expect
            body = JSON.parse(response.body)
            response_data = body["registration"]
            puts "response_data: #{response_data}"

            updated_registration = Registration.find("#{registration_update['competition_id']}-#{registration_update['user_id']}")
            puts updated_registration.inspect

            expect(response_data["registered_event_ids"]).to eq([])
            expect(response_data["registration_status"]).to eq("cancelled")

            # Make sure the registration stored in the dabatase contains teh values we expect
            expect(updated_registration.registered_event_ids).to eq([])
            expect(updated_registration.competing_status).to eq("cancelled")
          end
        end

        response '200', 'PASSING admin cancel update_pending registration' do
          # This method is not asynchronous so we're looking for a 200
          let(:registration_update) { @cancellation_818 }
          let(:Authorization) { @admin_token }

          run_test! do |response|
            # Make sure body contains the values we expect
            body = JSON.parse(response.body)
            response_data = body["registration"]
            puts "response_data: #{response_data}"

            updated_registration = Registration.find("#{registration_update['competition_id']}-#{registration_update['user_id']}")
            puts updated_registration.inspect

            expect(response_data["registered_event_ids"]).to eq([])
            expect(response_data["registration_status"]).to eq("cancelled")

            # Make sure the registration stored in the dabatase contains teh values we expect
            expect(updated_registration.registered_event_ids).to eq([])
            expect(updated_registration.competing_status).to eq("cancelled")
          end
        end

        response '200', 'PASSING admin cancel waiting_list registration' do
          # This method is not asynchronous so we're looking for a 200
          let(:registration_update) { @cancellation_819 }
          let(:Authorization) { @admin_token }

          run_test! do |response|
            # Make sure body contains the values we expect
            body = JSON.parse(response.body)
            response_data = body["registration"]
            puts "response_data: #{response_data}"

            updated_registration = Registration.find("#{registration_update['competition_id']}-#{registration_update['user_id']}")
            puts updated_registration.inspect

            expect(response_data["registered_event_ids"]).to eq([])
            expect(response_data["registration_status"]).to eq("cancelled")

            # Make sure the registration stored in the dabatase contains teh values we expect
            expect(updated_registration.registered_event_ids).to eq([])
            expect(updated_registration.competing_status).to eq("cancelled")
          end
        end

        response '200', 'PASSING admin cancel cancelled registration' do
          # This method is not asynchronous so we're looking for a 200
          let(:registration_update) { @cancellation_823 }
          let(:Authorization) { @admin_token }

          run_test! do |response|
            # Make sure body contains the values we expect
            body = JSON.parse(response.body)
            response_data = body["registration"]
            puts "response_data: #{response_data}"

            updated_registration = Registration.find("#{registration_update['competition_id']}-#{registration_update['user_id']}")
            puts updated_registration.inspect

            expect(response_data["registered_event_ids"]).to eq([])
            expect(response_data["registration_status"]).to eq("cancelled")

            # Make sure the registration stored in the dabatase contains teh values we expect
            expect(updated_registration.registered_event_ids).to eq([])
            expect(updated_registration.competing_status).to eq("cancelled")
          end
        end

        response '200', 'PASSING organizer cancels their own registration' do
          # This method is not asynchronous so we're looking for a 200
          let(:registration_update) { @cancellation_1 }
          let(:Authorization) { @organizer_token }

          run_test! do |response|
            # Make sure body contains the values we expect
            body = JSON.parse(response.body)
            response_data = body["registration"]
            puts "response_data: #{response_data}"

            updated_registration = Registration.find("#{registration_update['competition_id']}-#{registration_update['user_id']}")
            puts updated_registration.inspect

            expect(response_data["registered_event_ids"]).to eq([])
            expect(response_data["registration_status"]).to eq("cancelled")

            # Make sure the registration stored in the dabatase contains teh values we expect
            expect(updated_registration.registered_event_ids).to eq([])
            expect(updated_registration.competing_status).to eq("cancelled")
          end
        end

        response '200', 'PASSING organizer cancel accepted registration' do
          # This method is not asynchronous so we're looking for a 200
          let(:registration_update) { @cancellation_816 }
          let(:Authorization) { @organizer_token }

          run_test! do |response|
            # Make sure body contains the values we expect
            body = JSON.parse(response.body)
            response_data = body["registration"]
            puts "response_data: #{response_data}"

            updated_registration = Registration.find("#{registration_update['competition_id']}-#{registration_update['user_id']}")
            puts updated_registration.inspect

            expect(response_data["registered_event_ids"]).to eq([])
            expect(response_data["registration_status"]).to eq("cancelled")

            # Make sure the registration stored in the dabatase contains teh values we expect
            expect(updated_registration.registered_event_ids).to eq([])
            expect(updated_registration.competing_status).to eq("cancelled")
          end
        end

        response '200', 'PASSING organizer cancel accepted registration with comment' do
          # This method is not asynchronous so we're looking for a 200
          let(:registration_update) { @cancellation_816_2 }
          let(:Authorization) { @organizer_token }

          run_test! do |response|
            # Make sure body contains the values we expect
            body = JSON.parse(response.body)
            response_data = body["registration"]
            puts "response_data: #{response_data}"

            updated_registration = Registration.find("#{registration_update['competition_id']}-#{registration_update['user_id']}")
            puts updated_registration.inspect

            expect(response_data["registered_event_ids"]).to eq([])
            expect(response_data["registration_status"]).to eq("cancelled")

            # Make sure the registration stored in the dabatase contains teh values we expect
            expect(updated_registration.registered_event_ids).to eq([])
            expect(updated_registration.competing_status).to eq("cancelled")

            expect(updated_registration.admin_comment).to eq(registration_update["competing"]["admin_comment"])
          end
        end

        response '200', 'PASSING organizer cancel pending registration' do
          # This method is not asynchronous so we're looking for a 200
          let(:registration_update) { @cancellation_817 }
          let(:Authorization) { @admin_token }

          run_test! do |response|
            # Make sure body contains the values we expect
            body = JSON.parse(response.body)
            response_data = body["registration"]
            puts "response_data: #{response_data}"

            updated_registration = Registration.find("#{registration_update['competition_id']}-#{registration_update['user_id']}")
            puts updated_registration.inspect

            expect(response_data["registered_event_ids"]).to eq([])
            expect(response_data["registration_status"]).to eq("cancelled")

            # Make sure the registration stored in the dabatase contains teh values we expect
            expect(updated_registration.registered_event_ids).to eq([])
            expect(updated_registration.competing_status).to eq("cancelled")
          end
        end

        response '200', 'PASSING organizer cancel update_pending registration' do
          # This method is not asynchronous so we're looking for a 200
          let(:registration_update) { @cancellation_818 }
          let(:Authorization) { @organizer_token }

          run_test! do |response|
            # Make sure body contains the values we expect
            body = JSON.parse(response.body)
            response_data = body["registration"]
            puts "response_data: #{response_data}"

            updated_registration = Registration.find("#{registration_update['competition_id']}-#{registration_update['user_id']}")
            puts updated_registration.inspect

            expect(response_data["registered_event_ids"]).to eq([])
            expect(response_data["registration_status"]).to eq("cancelled")

            # Make sure the registration stored in the dabatase contains teh values we expect
            expect(updated_registration.registered_event_ids).to eq([])
            expect(updated_registration.competing_status).to eq("cancelled")
          end
        end

        response '200', 'PASSING organizer cancel waiting_list registration' do
          # This method is not asynchronous so we're looking for a 200
          let(:registration_update) { @cancellation_819 }
          let(:Authorization) { @organizer_token }

          run_test! do |response|
            # Make sure body contains the values we expect
            body = JSON.parse(response.body)
            response_data = body["registration"]
            puts "response_data: #{response_data}"

            updated_registration = Registration.find("#{registration_update['competition_id']}-#{registration_update['user_id']}")
            puts updated_registration.inspect

            expect(response_data["registered_event_ids"]).to eq([])
            expect(response_data["registration_status"]).to eq("cancelled")

            # Make sure the registration stored in the dabatase contains teh values we expect
            expect(updated_registration.registered_event_ids).to eq([])
            expect(updated_registration.competing_status).to eq("cancelled")
          end
        end

        response '200', 'PASSING organizer cancel cancelled registration' do
          # This method is not asynchronous so we're looking for a 200
          let(:registration_update) { @cancellation_823 }
          let(:Authorization) { @organizer_token }

          run_test! do |response|
            # Make sure body contains the values we expect
            body = JSON.parse(response.body)
            response_data = body["registration"]
            puts "response_data: #{response_data}"

            updated_registration = Registration.find("#{registration_update['competition_id']}-#{registration_update['user_id']}")
            puts updated_registration.inspect

            expect(response_data["registered_event_ids"]).to eq([])
            expect(response_data["registration_status"]).to eq("cancelled")

            # Make sure the registration stored in the dabatase contains teh values we expect
            expect(updated_registration.registered_event_ids).to eq([])
            expect(updated_registration.competing_status).to eq("cancelled")
          end
        end
      end

      context 'FAIL: registration cancellations' do
        # xAdd bad competition ID
        # Add other fields included
        # xAdd bad user ID
        include_context 'PATCH payloads'
        include_context 'database seed'
        include_context 'competition information'
        include_context 'auth_tokens'

        response '401', 'PASSING user tries to submit an admin payload' do
          error_response = { error: ErrorCodes::USER_INSUFFICIENT_PERMISSIONS }.to_json
          let(:registration_update) { @cancellation_816_2 }
          let(:Authorization) { @jwt_816 }

          run_test! do |response|
            expect(response.body).to eq(error_response)
          end
        end

        response '401', 'PASSING admin submits cancellation for a comp they arent an admin for' do
          # This could return an insufficient permissions error instead if we want to somehow determine who should be an admin
          error_response = { error: ErrorCodes::USER_INSUFFICIENT_PERMISSIONS }.to_json
          let(:registration_update) { @cancellation_073 }
          let(:Authorization) { @organizer_token }

          run_test! do |response|
            expect(response.body).to eq(error_response)
          end
        end

        response '401', 'PASSING user submits a cancellation for a different user' do
          error_response = { error: ErrorCodes::USER_INSUFFICIENT_PERMISSIONS }.to_json
          let(:registration_update) { @cancellation_816 }
          let(:Authorization) { @jwt_817 }

          run_test! do |response|
            expect(response.body).to eq(error_response)
          end
        end

        response '404', 'PASSING cancel on competition that doesnt exist' do
          registration_error_json = { error: ErrorCodes::COMPETITION_NOT_FOUND }.to_json
          let(:registration_update) { @bad_comp_cancellation }
          let(:Authorization) { @jwt_816 }

          run_test! do |reponse|
            expect(response.body).to eq(registration_error_json)
          end
        end

        response '404', 'PASSING cancel on competitor ID that isnt registered' do
          registration_error_json = { error: ErrorCodes::REGISTRATION_NOT_FOUND }.to_json
          let(:registration_update) { @bad_user_cancellation }
          let(:Authorization) { @jwt_800 }

          run_test! do |reponse|
            expect(response.body).to eq(registration_error_json)
          end
        end

        response '422', 'PASSING reject cancel with changed event ids' do
          # This test is passing, but the expect/to eq logic is wronng. old_event_ids is showing the updated event ids
          registration_error_json = { error: ErrorCodes::INVALID_EVENT_SELECTION }.to_json
          let(:registration_update) { @cancellation_with_events }
          let(:Authorization) { @jwt_816 }

          # Use separate before/it so that we can read the old event IDs before Registration object is updated
          before do |example|
            @old_event_ids = Registration.find("#{registration_update['competition_id']}-#{registration_update["user_id"]}").event_ids
            @response = submit_request(example.metadata)
          end

          it 'returns a 422' do |example|
            # run_test! do |response|
            body = JSON.parse(response.body)
            body["registration"]

            updated_registration = Registration.find("#{registration_update['competition_id']}-#{registration_update['user_id']}")

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
