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

        response '200', 'TESTING user removes events: events list updates' do
          let(:registration_update) { @events_update_2 }
          let(:Authorization) { @jwt_817 }

          run_test! do |response|
            target_registration = Registration.find("#{registration_update['competition_id']}-#{registration_update['user_id']}")
            expect(target_registration.event_ids).to eq(registration_update['event_ids'])
          end
        end

        response '200', 'FAILING user adds events: statuses update' do
        end

        response '200', 'FAILING user removes events: statuses update' do
        end
      end

      context 'ADMIN successful update requests' do
        # can advance status
        include_context 'PATCH payloads'
        include_context 'database seed'
        include_context 'auth_tokens'

        response '200', 'FAILING admin advances status [THIS NEEDS ITERATIONS FOR ALL POSSIBLE STATUS CHANGES]' do
        end

        response '200', 'FAILING admin accepts registration' do
        end

        response '200', 'FAILING admin cancels registration' do
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
      end

      context 'ADMIN failed update requests' do
        # can't advance status to accepted when competitor limit is reached
        include_context 'PATCH payloads'
        include_context 'database seed'
        include_context 'auth_tokens'
      end
    end
  end
end
