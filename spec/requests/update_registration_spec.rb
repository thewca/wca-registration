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
        include_context 'PATCH payloads'
        include_context 'database seed'
        include_context 'auth_tokens'

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

        response '200', 'PASSING user change number of guests' do
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
        # can't affect registration of other user (comment, guest, status, events)
        # can't advance status of their own reg
        include_context 'PATCH payloads'
        include_context 'database seed'
        include_context 'auth_tokens'

        response '200', 'FAILING user submits more guests than allowed' do
        end

        response '200', 'FAILING user submits longer comment than allowed' do
        end

        response '200', 'FAILING user removes all events' do
        end

        response '200', 'FAILING user adds events which arent present' do
        end

        response '200', 'FAILING user requests status change thy arent allowed to' do
        end
      end

      context 'ADMIN failed update requests' do
        # can't advance status to accepted when competitor limit is reached
        include_context 'PATCH payloads'
        include_context 'database seed'
        include_context 'auth_tokens'

        response '422', 'PASSING admin changes to status which doesnt exist' do
          let(:registration_update) { @invalid_status_update }
          let(:Authorization) { @admin_token }
          registration_error =  { error: ErrorCodes::INALID_REQUEST_DATA }.to_json

          run_test! do |response|
            expect(response.body).to eq(registration_error)
          end
        end
      end
    end
  end
end
