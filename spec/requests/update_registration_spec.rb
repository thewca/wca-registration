# frozen_string_literal: true

require 'swagger_helper'
require_relative '../../app/helpers/error_codes'

RSpec.describe 'v1 Registrations API', type: :request, document: false do
  include Helpers::RegistrationHelper

  path '/api/v1/register' do
    patch 'update or cancel an attendee registration' do
      security [Bearer: {}]
      consumes 'application/json'
      parameter name: :registration_update, in: :body,
                schema: { '$ref' => '#/components/schemas/updateRegistrationBody' }, required: true

      produces 'application/json'

      context 'USER successful update requests' do
        before do
          competition = FactoryBot.build(:competition)
          stub_request(:get, comp_api_url(competition['competition_id'])).to_return(status: 200, body: competition.to_json)
        end

        response '200', 'PASSING user changes comment' do
          schema type: :object,
                 properties: {
                   status: { type: :string },
                   registration: { '$ref' => '#/components/schemas/registrationAdmin' },
                 }

          before { FactoryBot.create(:registration, comment: 'starting comment') }

          update = FactoryBot.build(:update_payload, update_details: { 'comment' => 'updated registration comment' })
          let(:registration_update) { update }
          let(:Authorization) { update[:jwt_token] }

          run_test! do |response|
            target_registration = Registration.find("#{registration_update[:competition_id]}-#{registration_update[:user_id]}")
            expect(target_registration.competing_comment).to eq('updated registration comment')
          end
        end

        response '200', 'PASSING user adds comment to reg with no comment' do
          before { FactoryBot.create(:registration) }

          update = FactoryBot.build(:update_payload, update_details: { 'comment' => 'updated registration comment - had no comment before' })
          let(:registration_update) { update }
          let(:Authorization) { update[:jwt_token] }

          run_test! do |response|
            target_registration = Registration.find("#{registration_update[:competition_id]}-#{registration_update[:user_id]}")
            expect(target_registration.competing_comment).to eq('updated registration comment - had no comment before')
          end
        end

        response '200', 'FAILING user adds guests, none existed before' do
          before { FactoryBot.create(:registration) }

          update = FactoryBot.build(:update_payload, update_details: { 'guests' => 2 })
          let(:registration_update) { update }
          let(:Authorization) { update[:jwt_token] }

          run_test! do |response|
            target_registration = Registration.find("#{registration_update[:competition_id]}-#{registration_update[:user_id]}")
            expect(target_registration.competing_guests).to eq(2)
          end
        end

        response '200', 'FAILING user changes number of guests' do
          let(:registration_update) { @guest_update_2 }
          let(:Authorization) { @jwt_817 }

          run_test! do |response|
            target_registration = Registration.find("#{registration_update['competition_id']}-#{registration_update['user_id']}")
            expect(target_registration.competing_guests).to eq(2)
          end
        end

        response '200', 'PASSING user adds events: events list updates' do
          before { FactoryBot.create(:registration) }

          update = FactoryBot.build(:update_payload, update_details: { 'event_ids' => ['333', '333mbf', '555', '666', '777'] })
          let(:registration_update) { update }
          let(:Authorization) { update[:jwt_token] }

          run_test! do |response|
            target_registration = Registration.find("#{registration_update[:competition_id]}-#{registration_update[:user_id]}")
            puts registration_update
            expect(target_registration.event_ids).to eq(registration_update[:competing]['event_ids'])
          end
        end

        response '200', 'PASSING user removes events: events list updates' do
          before { FactoryBot.create(:registration) }

          update = FactoryBot.build(:update_payload, update_details: { 'event_ids' => ['333'] })
          let(:registration_update) { update }
          let(:Authorization) { update[:jwt_token] }

          run_test! do |response|
            target_registration = Registration.find("#{registration_update[:competition_id]}-#{registration_update[:user_id]}")
            expect(target_registration.event_ids).to eq(registration_update[:competing]['event_ids'])
          end
        end

        response '200', 'PASSING user adds events: statuses update' do
          before { FactoryBot.create(:registration, lane_state: 'accepted') }

          update = FactoryBot.build(:update_payload, update_details: { 'event_ids' => ['333', '333mbf', '555', '666', '777'] })
          let(:registration_update) { update }
          let(:Authorization) { update[:jwt_token] }

          run_test! do |response|
            target_registration = Registration.find("#{registration_update[:competition_id]}-#{registration_update[:user_id]}")

            event_details = target_registration.event_details
            registration_status = target_registration.competing_status
            event_details.each do |event|
              puts "event: #{event}"
              expect(event['event_registration_state']).to eq(registration_status)
            end
          end
        end

        response '200', 'PASSING user removes events: statuses update' do
          before { FactoryBot.create(:registration) }

          update = FactoryBot.build(:update_payload, update_details: { 'event_ids' => ['333'] })
          let(:registration_update) { update }
          let(:Authorization) { update[:jwt_token] }

          run_test! do |response|
            target_registration = Registration.find("#{registration_update[:competition_id]}-#{registration_update[:user_id]}")

            event_details = target_registration.event_details
            registration_status = target_registration.competing_status
            event_details.each do |event|
              puts "event: #{event}"
              expect(event['event_registration_state']).to eq(registration_status)
            end
          end
        end
      end

      context 'ADMIN successful update requests' do
        before do
          competition = FactoryBot.build(:competition)
          stub_request(:get, comp_api_url(competition['competition_id'])).to_return(status: 200, body: competition.to_json)
        end

        response '200', 'PASSING admin state pending -> accepted' do
          before { FactoryBot.create(:registration, lane_state: 'pending') }

          update = FactoryBot.build(:update_payload, :admin_for_user, update_details: { 'status' => 'accepted' })
          let(:registration_update) { update }
          let(:Authorization) { update[:jwt_token] }

          run_test! do |response|
            target_registration = Registration.find("#{registration_update[:competition_id]}-#{registration_update[:user_id]}")
            competing_status = target_registration.competing_status
            event_details = target_registration.event_details

            # Check competing status is correct
            expect(competing_status).to eq('accepted')

            # Check that event states are correct
            event_details.each do |event|
              expect(event['event_registration_state']).to eq('accepted')
            end
          end
        end

        response '200', 'PASSING admin state pending -> waiting_list' do
          before { FactoryBot.create(:registration, lane_state: 'pending') }

          update = FactoryBot.build(:update_payload, :admin_for_user, update_details: { 'status' => 'waiting_list' })
          let(:registration_update) { update }
          let(:Authorization) { update[:jwt_token] }

          run_test! do |response|
            target_registration = Registration.find("#{registration_update[:competition_id]}-#{registration_update[:user_id]}")
            competing_status = target_registration.competing_status
            event_details = target_registration.event_details

            # Check competing status is correct
            expect(competing_status).to eq('waiting_list')

            # Check that event states are correct
            event_details.each do |event|
              expect(event['event_registration_state']).to eq('waiting_list')
            end
          end
        end

        response '200', 'PASSING admin state waiting_list -> accepted' do
          before { FactoryBot.create(:registration, lane_state: 'pending') }

          update = FactoryBot.build(:update_payload, :admin_for_user, update_details: { 'status' => 'accepted' })
          let(:registration_update) { update }
          let(:Authorization) { update[:jwt_token] }

          run_test! do |response|
            target_registration = Registration.find("#{registration_update[:competition_id]}-#{registration_update[:user_id]}")
            competing_status = target_registration.competing_status
            event_details = target_registration.event_details

            # Check competing status is correct
            expect(competing_status).to eq('accepted')

            # Check that event states are correct
            event_details.each do |event|
              expect(event['event_registration_state']).to eq('accepted')
            end
          end
        end

        response '200', 'PASSING admin state waiting_list -> pending' do
          before { FactoryBot.create(:registration, lane_state: 'waiting_list') }

          update = FactoryBot.build(:update_payload, :admin_for_user, update_details: { 'status' => 'pending' })
          let(:registration_update) { update }
          let(:Authorization) { update[:jwt_token] }

          run_test! do |response|
            target_registration = Registration.find("#{registration_update[:competition_id]}-#{registration_update[:user_id]}")
            competing_status = target_registration.competing_status
            event_details = target_registration.event_details

            # Check competing status is correct
            expect(competing_status).to eq('pending')

            # Check that event states are correct
            event_details.each do |event|
              expect(event['event_registration_state']).to eq('pending')
            end
          end
        end

        response '200', 'PASSING admin state accepted -> pending' do
          before { FactoryBot.create(:registration, lane_state: 'accepted') }

          update = FactoryBot.build(:update_payload, :admin_for_user, update_details: { 'status' => 'pending' })
          let(:registration_update) { update }
          let(:Authorization) { update[:jwt_token] }

          run_test! do |response|
            target_registration = Registration.find("#{registration_update[:competition_id]}-#{registration_update[:user_id]}")
            competing_status = target_registration.competing_status
            event_details = target_registration.event_details

            # Check competing status is correct
            expect(competing_status).to eq('pending')

            # Check that event states are correct
            event_details.each do |event|
              expect(event['event_registration_state']).to eq('pending')
            end
          end
        end

        response '200', 'PASSING admin state accepted -> waiting_list' do
          before { FactoryBot.create(:registration, lane_state: 'accepted') }

          update = FactoryBot.build(:update_payload, :admin_for_user, update_details: { 'status' => 'waiting_list' })
          let(:registration_update) { update }
          let(:Authorization) { update[:jwt_token] }

          run_test! do |response|
            target_registration = Registration.find("#{registration_update[:competition_id]}-#{registration_update[:user_id]}")
            competing_status = target_registration.competing_status
            event_details = target_registration.event_details

            # Check competing status is correct
            expect(competing_status).to eq('waiting_list')

            # Check that event states are correct
            event_details.each do |event|
              expect(event['event_registration_state']).to eq('waiting_list')
            end
          end
        end
      end

      context 'USER failed update requests' do
        before do
          competition = FactoryBot.build(:competition)
          stub_request(:get, comp_api_url(competition['competition_id'])).to_return(status: 200, body: competition.to_json)
        end

        response '422', 'PASSING user does not include required comment' do
          schema '$ref' => '#/components/schemas/error_response'
          before do
            competition = FactoryBot.build(:competition, force_comment_in_registration: true)
            stub_request(:get, comp_api_url(competition['competition_id'])).to_return(status: 200, body: competition.to_json)
            FactoryBot.create(:registration)
          end

          update = FactoryBot.build(:update_payload, update_details: { 'event_ids' => ['333', '333mbf', '555', '666', '777'] })
          let(:registration_update) { update }
          let(:Authorization) { update[:jwt_token] }

          registration_error = { error: ErrorCodes::REQUIRED_COMMENT_MISSING }.to_json

          run_test! do |response|
            expect(response.body).to eq(registration_error)
          end
        end

        response '422', 'FAILING user submits more guests than allowed' do
          registration_error = { error: ErrorCodes::GUEST_LIMIT_EXCEEDED }.to_json
          let(:registration_update) { @guest_update_3 }
          let(:Authorization) { @jwt_817 }

          run_test! do |response|
            expect(response.body).to eq(registration_error)
          end
        end

        response '422', 'PASSING user submits longer comment than allowed' do
          before { FactoryBot.create(:registration) }

          long_comment = 'comment longer than 240 characterscomment longer than 240 characterscomment longer than 240 characterscomment longer than 240 characterscomment longer than 240 characterscomment longer than 240 characterscomment longer
            than 240 characterscomment longer than 240 characters'
          update = FactoryBot.build(:update_payload, update_details: { 'comment' => long_comment })
          let(:registration_update) { update }
          let(:Authorization) { update[:jwt_token] }

          registration_error = { error: ErrorCodes::USER_COMMENT_TOO_LONG }.to_json

          run_test! do |response|
            expect(response.body).to eq(registration_error)
          end
        end

        response '422', 'PASSING user removes all events - no status provided' do
          before { FactoryBot.create(:registration) }

          update = FactoryBot.build(:update_payload, update_details: { 'event_ids' => [] })
          let(:registration_update) { update }
          let(:Authorization) { update[:jwt_token] }

          registration_error = { error: ErrorCodes::INVALID_EVENT_SELECTION }.to_json

          run_test! do |response|
            expect(response.body).to eq(registration_error)
          end
        end

        response '422', 'PASSING user adds events which arent present' do
          before { FactoryBot.create(:registration) }

          update = FactoryBot.build(:update_payload, update_details: { 'event_ids' => ['333fm', '333'] })
          let(:registration_update) { update }
          let(:Authorization) { update[:jwt_token] }

          registration_error = { error: ErrorCodes::INVALID_EVENT_SELECTION }.to_json

          run_test! do |response|
            expect(response.body).to eq(registration_error)
          end
        end

        response '422', 'PASSING user adds events which dont exist' do
          before { FactoryBot.create(:registration) }

          update = FactoryBot.build(:update_payload, update_details: { 'event_ids' => ['333', '888'] })
          let(:registration_update) { update }
          let(:Authorization) { update[:jwt_token] }

          registration_error = { error: ErrorCodes::INVALID_EVENT_SELECTION }.to_json

          run_test! do |response|
            expect(response.body).to eq(registration_error)
          end
        end

        response '401', 'PASSING user requests invalid status change to their own reg' do
          schema '$ref' => '#/components/schemas/error_response'
          before { FactoryBot.create(:registration, lane_state: 'pending') }

          update = FactoryBot.build(:update_payload, update_details: { 'status' => 'accepted' })
          let(:registration_update) { update }
          let(:Authorization) { update[:jwt_token] }

          registration_error = { error: ErrorCodes::USER_INSUFFICIENT_PERMISSIONS }.to_json

          run_test! do |response|
            target_registration = Registration.find("#{registration_update[:competition_id]}-#{registration_update[:user_id]}")
            competing_status = target_registration.competing_status
            event_details = target_registration.event_details

            # Check error message
            expect(response.body).to eq(registration_error)

            # Check competing status is correct
            expect(competing_status).to eq('pending')

            # Check that event states are correct
            event_details.each do |event|
              expect(event['event_registration_state']).to eq('pending')
            end
          end
        end

        response '401', 'PASSING user requests status change to someone elses reg' do
          before { FactoryBot.create(:registration, lane_state: 'pending') }

          update = FactoryBot.build(:update_payload, :for_another_user, update_details: { 'status' => 'accepted' })
          let(:registration_update) { update }
          let(:Authorization) { update[:jwt_token] }

          registration_error = { error: ErrorCodes::USER_INSUFFICIENT_PERMISSIONS }.to_json

          run_test! do |response|
            target_registration = Registration.find("#{registration_update[:competition_id]}-#{registration_update[:user_id]}")
            competing_status = target_registration.competing_status
            event_details = target_registration.event_details

            # Check error message
            expect(response.body).to eq(registration_error)

            # Check competing status is correct
            expect(competing_status).to eq('pending')

            # Check that event states are correct
            event_details.each do |event|
              expect(event['event_registration_state']).to eq('pending')
            end
          end
        end

        response '403', 'PASSING user changes events / other stuff past deadline' do
          schema '$ref' => '#/components/schemas/error_response'
          before do
            competition = FactoryBot.build(:competition, event_change_deadline_date: '2023-06-14T00:00:00.000Z')
            stub_request(:get, comp_api_url(competition['competition_id'])).to_return(status: 200, body: competition.to_json)
            FactoryBot.create(:registration)
          end

          update = FactoryBot.build(:update_payload, update_details: { 'event_ids' => ['333', '333mbf', '555', '666', '777'] })
          let(:registration_update) { update }
          let(:Authorization) { update[:jwt_token] }

          registration_error = { error: ErrorCodes::EVENT_EDIT_DEADLINE_PASSED }.to_json

          run_test! do |response|
            expect(response.body).to eq(registration_error)
          end
        end
      end

      context 'ADMIN failed update requests' do
        before do
          competition = FactoryBot.build(:competition)
          stub_request(:get, comp_api_url(competition['competition_id'])).to_return(status: 200, body: competition.to_json)
        end

        response '422', 'PASSING admin changes to status which doesnt exist' do
          before { FactoryBot.create(:registration, lane_state: 'waiting_list') }

          update = FactoryBot.build(:update_payload, :admin_for_user, update_details: { 'status' => 'random_status' })
          let(:registration_update) { update }
          let(:Authorization) { update[:jwt_token] }

          registration_error =  { error: ErrorCodes::INVALID_REQUEST_DATA }.to_json

          run_test! do |response|
            expect(response.body).to eq(registration_error)
          end
        end

        response '403', 'PASSING admin cannot advance state when registration full' do
          before do
            competition = FactoryBot.build(:competition, competitor_limit: 2)
            stub_request(:get, comp_api_url(competition['competition_id'])).to_return(status: 200, body: competition.to_json)
            FactoryBot.create(:registration, lane_state: 'accepted')
            FactoryBot.create(:registration, user_id: '110888', lane_state: 'accepted')
            FactoryBot.create(:registration, user_id: '200000', lane_state: 'pending')
          end

          registration_error = { error: ErrorCodes::COMPETITOR_LIMIT_REACHED }.to_json

          update = FactoryBot.build(:update_payload, :admin_for_user, user_id: 200_000, update_details: { 'status' => 'accepted' })
          let(:registration_update) { update }
          let(:Authorization) { update[:jwt_token] }

          run_test! do |response|
            expect(response.body).to eq(registration_error)

            target_registration = Registration.find("#{registration_update[:competition_id]}-#{registration_update[:user_id]}")
            competing_status = target_registration.competing_status
            event_details = target_registration.event_details

            # Check competing status is correct
            expect(competing_status).to eq('pending')

            # Check that event states are correct
            event_details.each do |event|
              expect(event['event_registration_state']).to eq('pending')
            end
          end
        end
      end
    end
  end
end
