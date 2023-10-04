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

      context 'USER successful update requests' do
        include_context 'competition information'
        include_context 'PATCH payloads'
        include_context 'database seed'
        include_context 'auth_tokens'

        response '200', 'PASSING user passes empty event_ids - with deleted status' do
          let(:registration_update) { @events_update_5 }
          let(:Authorization) { @jwt_817 }

          run_test!
        end

        response '200', 'PASSING user changes comment' do
          let(:registration_update) { @comment_update }
          let(:Authorization) { @jwt_816 }

          run_test! do |response|
            target_registration = Registration.find("#{registration_update['competition_id']}-#{registration_update['user_id']}")
            expect(target_registration.competing_comment).to eq("updated registration comment")
          end
        end

        response '200', 'PASSING user adds comment to reg with no comment' do
          let(:registration_update) { @comment_update_2 }
          let(:Authorization) { @jwt_817 }

          run_test! do |response|
            target_registration = Registration.find("#{registration_update['competition_id']}-#{registration_update['user_id']}")
            expect(target_registration.competing_comment).to eq("updated registration comment - had no comment before")
          end
        end

        response '200', 'PASSING user adds guests, none existed before' do
          let(:registration_update) { @guest_update_1 }
          let(:Authorization) { @jwt_816 }

          run_test! do |response|
            target_registration = Registration.find("#{registration_update['competition_id']}-#{registration_update['user_id']}")
            expect(target_registration.competing_guests).to eq(2)
          end
        end

        response '200', 'PASSING user changes number of guests' do
          let(:registration_update) { @guest_update_2 }
          let(:Authorization) { @jwt_817 }

          run_test! do |response|
            target_registration = Registration.find("#{registration_update['competition_id']}-#{registration_update['user_id']}")
            expect(target_registration.competing_guests).to eq(2)
          end
        end

        response '200', 'PASSING user adds events: events list updates' do
          let(:registration_update) { @events_update_1 }
          let(:Authorization) { @jwt_816 }

          run_test! do |response|
            target_registration = Registration.find("#{registration_update['competition_id']}-#{registration_update['user_id']}")
            expect(target_registration.event_ids).to eq(registration_update['event_ids'])
          end
        end

        response '200', 'PASSING user removes events: events list updates' do
          let(:registration_update) { @events_update_2 }
          let(:Authorization) { @jwt_817 }

          run_test! do |response|
            target_registration = Registration.find("#{registration_update['competition_id']}-#{registration_update['user_id']}")
            expect(target_registration.event_ids).to eq(registration_update['event_ids'])
          end
        end

        response '200', 'PASSING user adds events: statuses update' do
          let(:registration_update) { @events_update_1 }
          let(:Authorization) { @jwt_816 }

          run_test! do |response|
            target_registration = Registration.find("#{registration_update['competition_id']}-#{registration_update['user_id']}")

            event_details = target_registration.event_details
            registration_status = target_registration.competing_status
            event_details.each do |event|
              puts "event: #{event}"
              expect(event["event_registration_state"]).to eq(registration_status)
            end
          end
        end

        response '200', 'PASSING user removes events: statuses update' do
          let(:registration_update) { @events_update_2 }
          let(:Authorization) { @jwt_817 }

          run_test! do |response|
            target_registration = Registration.find("#{registration_update['competition_id']}-#{registration_update['user_id']}")

            event_details = target_registration.event_details
            registration_status = target_registration.competing_status
            event_details.each do |event|
              puts "event: #{event}"
              expect(event["event_registration_state"]).to eq(registration_status)
            end
          end
        end
      end

      context 'ADMIN successful update requests' do
        # Note that delete/cancel tests are handled in cancel_registration_spec.rb
        include_context 'competition information'
        include_context 'PATCH payloads'
        include_context 'database seed'
        include_context 'auth_tokens'

        response '200', 'PASSING admin state pending -> accepted' do
          let(:registration_update) { @pending_update_1 }
          let(:Authorization) { @admin_token }

          run_test! do |response|
            target_registration = Registration.find("#{registration_update['competition_id']}-#{registration_update['user_id']}")
            competing_status = target_registration.competing_status
            event_details = target_registration.event_details

            # Check competing status is correct
            expect(competing_status).to eq('accepted')

            # Check that event states are correct
            event_details.each do |event|
              expect(event["event_registration_state"]).to eq('accepted')
            end
          end
        end

        response '200', 'PASSING admin state pending -> waiting_list' do
          let(:registration_update) { @pending_update_2 }
          let(:Authorization) { @admin_token }

          run_test! do |response|
            target_registration = Registration.find("#{registration_update['competition_id']}-#{registration_update['user_id']}")
            competing_status = target_registration.competing_status
            event_details = target_registration.event_details

            # Check competing status is correct
            expect(competing_status).to eq('waiting_list')

            # Check that event states are correct
            event_details.each do |event|
              expect(event["event_registration_state"]).to eq('waiting_list')
            end
          end
        end

        response '200', 'PASSING admin state waiting_list -> accepted' do
          let(:registration_update) { @waiting_update_1 }
          let(:Authorization) { @admin_token }

          run_test! do |response|
            target_registration = Registration.find("#{registration_update['competition_id']}-#{registration_update['user_id']}")
            competing_status = target_registration.competing_status
            event_details = target_registration.event_details

            # Check competing status is correct
            expect(competing_status).to eq('accepted')

            # Check that event states are correct
            event_details.each do |event|
              expect(event["event_registration_state"]).to eq('accepted')
            end
          end
        end

        response '200', 'PASSING admin state waiting_list -> pending' do
          let(:registration_update) { @waiting_update_2 }
          let(:Authorization) { @admin_token }

          run_test! do |response|
            target_registration = Registration.find("#{registration_update['competition_id']}-#{registration_update['user_id']}")
            competing_status = target_registration.competing_status
            event_details = target_registration.event_details

            # Check competing status is correct
            expect(competing_status).to eq('pending')

            # Check that event states are correct
            event_details.each do |event|
              expect(event["event_registration_state"]).to eq('pending')
            end
          end
        end

        response '200', 'PASSING admin state accepted -> pending' do
          let(:registration_update) { @accepted_update_1 }
          let(:Authorization) { @admin_token }

          run_test! do |response|
            target_registration = Registration.find("#{registration_update['competition_id']}-#{registration_update['user_id']}")
            competing_status = target_registration.competing_status
            event_details = target_registration.event_details

            # Check competing status is correct
            expect(competing_status).to eq('pending')

            # Check that event states are correct
            event_details.each do |event|
              expect(event["event_registration_state"]).to eq('pending')
            end
          end
        end

        response '200', 'PASSING admin state accepted -> waiting_list' do
          let(:registration_update) { @accepted_update_2 }
          let(:Authorization) { @admin_token }

          run_test! do |response|
            target_registration = Registration.find("#{registration_update['competition_id']}-#{registration_update['user_id']}")
            competing_status = target_registration.competing_status
            event_details = target_registration.event_details

            # Check competing status is correct
            expect(competing_status).to eq('waiting_list')

            # Check that event states are correct
            event_details.each do |event|
              expect(event["event_registration_state"]).to eq('waiting_list')
            end
          end
        end
      end

      context 'USER failed update requests' do
        include_context 'competition information'
        include_context 'PATCH payloads'
        include_context 'database seed'
        include_context 'auth_tokens'

        response '422', 'PASSING user does not include required comment' do
          registration_error = { error: ErrorCodes::REQUIRED_COMMENT_MISSING }.to_json
          let(:registration_update) { @comment_update_4 }
          let(:Authorization) { @jwt_820 }

          run_test! do |response|
            expect(response.body).to eq(registration_error)
          end
        end

        response '422', 'PASSING user submits more guests than allowed' do
          registration_error = { error: ErrorCodes::GUEST_LIMIT_EXCEEDED }.to_json
          let(:registration_update) { @guest_update_3 }
          let(:Authorization) { @jwt_817 }

          run_test! do |response|
            expect(response.body).to eq(registration_error)
          end
        end

        response '422', 'PASSING user submits longer comment than allowed' do
          registration_error = { error: ErrorCodes::USER_COMMENT_TOO_LONG }.to_json
          let(:registration_update) { @comment_update_3 }
          let(:Authorization) { @jwt_817 }

          run_test! do |response|
            expect(response.body).to eq(registration_error)
          end
        end

        response '422', 'PASSING user removes all events - no status provided' do
          registration_error = { error: ErrorCodes::INVALID_EVENT_SELECTION }.to_json
          let(:registration_update) { @events_update_3 }
          let(:Authorization) { @jwt_817 }

          run_test! do |response|
            expect(response.body).to eq(registration_error)
          end
        end

        response '422', 'PASSING user adds events which arent present' do
          registration_error = { error: ErrorCodes::INVALID_EVENT_SELECTION }.to_json
          let(:registration_update) { @events_update_6 }
          let(:Authorization) { @jwt_817 }

          run_test! do |response|
            expect(response.body).to eq(registration_error)
          end
        end

        response '422', 'PASSING user adds events which dont exist' do
          registration_error = { error: ErrorCodes::INVALID_EVENT_SELECTION }.to_json
          let(:registration_update) { @events_update_7 }
          let(:Authorization) { @jwt_817 }

          run_test! do |response|
            expect(response.body).to eq(registration_error)
          end
        end

        response '401', 'PASSING user requests invalid status change to their own reg' do
          registration_error = { error: ErrorCodes::USER_INSUFFICIENT_PERMISSIONS }.to_json
          let(:registration_update) { @pending_update_1 }
          let(:Authorization) { @jwt_817 }

          run_test! do |response|
            target_registration = Registration.find("#{registration_update['competition_id']}-#{registration_update['user_id']}")
            competing_status = target_registration.competing_status
            event_details = target_registration.event_details

            # Check error message
            expect(response.body).to eq(registration_error)

            # Check competing status is correct
            expect(competing_status).to eq('pending')

            # Check that event states are correct
            event_details.each do |event|
              expect(event["event_registration_state"]).to eq('pending')
            end
          end
        end

        response '401', 'PASSING user requests status change to someone elses reg' do
          registration_error = { error: ErrorCodes::USER_IMPERSONATION }.to_json
          let(:registration_update) { @pending_update_1 }
          let(:Authorization) { @jwt_816 }

          run_test! do |response|
            target_registration = Registration.find("#{registration_update['competition_id']}-#{registration_update['user_id']}")
            competing_status = target_registration.competing_status
            event_details = target_registration.event_details

            # Check error message
            expect(response.body).to eq(registration_error)

            # Check competing status is correct
            expect(competing_status).to eq('pending')

            # Check that event states are correct
            event_details.each do |event|
              expect(event["event_registration_state"]).to eq('pending')
            end
          end
        end

        response '403', 'PASSING user changes events / other stuff past deadline' do
          registration_error = { error: ErrorCodes::EVENT_EDIT_DEADLINE_PASSED }.to_json
          let(:registration_update) { @delayed_update_1 }
          let(:Authorization) { @jwt_820 }

          run_test! do |response|
            expect(response.body).to eq(registration_error)
          end
        end
      end

      context 'ADMIN failed update requests' do
        include_context 'competition information'
        include_context 'PATCH payloads'
        include_context 'database seed'
        include_context 'auth_tokens'

        response '422', 'PASSING admin changes to status which doesnt exist' do
          let(:registration_update) { @invalid_status_update }
          let(:Authorization) { @admin_token }
          registration_error =  { error: ErrorCodes::INVALID_REQUEST_DATA }.to_json

          run_test! do |response|
            expect(response.body).to eq(registration_error)
          end
        end

        response '403', 'PASSING admin cannot advance state when registration full' do
          registration_error = { error: ErrorCodes::COMPETITOR_LIMIT_REACHED }.to_json
          let(:registration_update) { @pending_update_3 }
          let(:Authorization) { @admin_token }

          run_test! do |response|
            expect(response.body).to eq(registration_error)

            target_registration = Registration.find("#{registration_update['competition_id']}-#{registration_update['user_id']}")
            competing_status = target_registration.competing_status
            event_details = target_registration.event_details

            # Check competing status is correct
            expect(competing_status).to eq('pending')

            # Check that event states are correct
            event_details.each do |event|
              expect(event["event_registration_state"]).to eq('pending')
            end
          end
        end
      end
    end
  end
end
