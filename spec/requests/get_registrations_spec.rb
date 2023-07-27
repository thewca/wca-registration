# frozen_string_literal: true

require 'swagger_helper'
require_relative '../support/registration_spec_helper'
require_relative '../../app/helpers/error_codes'

#x TODO: Add update logic from main for determining admin auth
#x TODO: Add explicit check for non-auth to return attending only
#x TODO: Add explicit cehck for auth to return all attendees irrespective of status
#x TODO: Add checks for test behaviour (ie number of items in return payload)
#x TODO: Add commented tests
# TODO: Check Swaggerized output
# TODO: Brainstorm other tests that could be included
RSpec.describe 'v1 Registrations API', type: :request do
  include Helpers::RegistrationHelper

  path '/api/v1/registrations/{competition_id}' do
    get 'Public: list registrations for a given competition_id' do
      parameter name: :competition_id, in: :path, type: :string, required: true
      produces 'application/json'

      context 'success responses' do
        include_context 'competition information'
        include_context 'database seed'

        response '200', 'PASSING request and response conform to schema' do
          schema type: :array, items: { '$ref' => '#/components/schemas/registration' }

          let!(:competition_id) { @attending_registrations_only }

          run_test! do |response|
            body = JSON.parse(response.body)
            expect(body.length).to eq(4)
          end
        end

        response '200', 'FAILING only returns attending registrations' do # waiting_list are being counted as is_attending - not sure how this is set? maybe in the model logic?
          let!(:competition_id) { @includes_non_attending_registrations }

          run_test! do |response|
            body = JSON.parse(response.body)
            expect(body.length).to eq(1)
          end
        end

        response '200', 'PASSING Valid competition_id but no registrations for it' do
          let!(:competition_id) { @empty_comp }

          run_test! do |response|
            body = JSON.parse(response.body)
            expect(body).to eq([])
          end
        end

        context 'Competition service down (500) but registrations exist' do
          response '200', 'PASSING comp service down but registrations exist' do
            let!(:competition_id) { @registrations_exist_comp_500 }

            run_test! do |response|
              body = JSON.parse(response.body)
              expect(body.length).to eq(3)
            end
          end
        end

        context 'Competition service down (502) but registrations exist' do
          response '200', 'PASSING comp service down but registrations exist' do
            let!(:competition_id) { @registrations_exist_comp_502 }

            run_test! do |response|
              body = JSON.parse(response.body)
              expect(body.length).to eq(2)
            end
          end
        end
      end

      context 'fail responses' do
        include_context 'competition information'
        include_context 'database seed'

        context 'PASSING competition_id not found by Competition Service' do
          registration_error_json = { error: ErrorCodes::COMPETITION_NOT_FOUND }.to_json

          response '404', 'Competition ID doesnt exist' do
            schema '$ref' => '#/components/schemas/error_response'
            let(:competition_id) { @error_comp_404 }

            run_test! do |response|
              expect(response.body).to eq(registration_error_json)
            end
          end
        end

        context '500 - competition service not available (500) and no registrations in our database for competition_id' do
          registration_error_json = { error: ErrorCodes::COMPETITION_API_5XX }.to_json
          response '500', 'PASSING Competition service unavailable - 500 error' do
            schema '$ref' => '#/components/schemas/error_response'
            let!(:competition_id) { @error_comp_500 }

            run_test! do |response|
              expect(response.body).to eq(registration_error_json)
            end
          end
        end

        context '502 - competition service not available - 502, and no registration for competition ID' do
          registration_error_json = { error: ErrorCodes::COMPETITION_API_5XX }.to_json
          response '502', 'PASSING Competition service unavailable - 502 error' do
            schema '$ref' => '#/components/schemas/error_response'
            let!(:competition_id) { @error_comp_502 }

            run_test! do |response|
              expect(response.body).to eq(registration_error_json)
            end
          end
        end
      end
    end
  end

  path '/api/v1/registrations/{competition_id}/admin' do
    get 'Public: list registrations for a given competition_id' do
      security [Bearer: {}]
      parameter name: :competition_id, in: :path, type: :string, required: true
      produces 'application/json'

      context 'success responses' do
        include_context 'competition information'
        include_context 'database seed'
        include_context 'auth_tokens'

        response '200', 'PASSING request and response conform to schema' do
          schema type: :array, items: { '$ref' => '#/components/schemas/registrationAdmin' }

          let!(:competition_id) { @attending_registrations_only }
          let(:'Authorization') { @admin_token }

          run_test! do |response|
            body = JSON.parse(response.body)
            expect(body.length).to eq(4)
          end
        end

        response '200', 'PASSING admin registration endpoint returns registrations in all states' do
          let!(:competition_id) { @includes_non_attending_registrations }
          let(:'Authorization') { @admin_token }

          run_test! do |response|
            body = JSON.parse(response.body)
            expect(body.length).to eq(5)
          end
        end

        # TODO user has competition-specific auth and can get all registrations
        response '200', 'PASSING organizer can access admin list for their competition' do
          let!(:competition_id) { @includes_non_attending_registrations }
          let(:'Authorization') { @organizer_token }

          run_test! do |response|
            body = JSON.parse(response.body)
            expect(body.length).to eq(5)
          end
        end

        context 'user has comp-specific auth for multiple comps' do
          response '200', 'PASSING organizer has access to comp 1' do
            let!(:competition_id) { @includes_non_attending_registrations }
            let(:'Authorization') { @multi_comp_organizer_token }

            run_test! do |response|
              body = JSON.parse(response.body)
              expect(body.length).to eq(5)
            end
          end

          response '200', 'PASSING organizer has access to comp 2' do
            let!(:competition_id) { @attending_registrations_only }
            let(:'Authorization') { @multi_comp_organizer_token }

            run_test! do |response|
              body = JSON.parse(response.body)
              expect(body.length).to eq(4)
            end
          end
        end
      end

      context 'fail responses' do
        include_context 'competition information'
        include_context 'database seed'
        include_context 'auth_tokens'

        response '403', 'PASSING Attending user cannot get admin registration list' do
          registration_error_json = { error: ErrorCodes::USER_INSUFFICIENT_PERMISSIONS }.to_json
          let!(:competition_id) { @attending_registrations_only }
          let(:'Authorization') { @jwt_token }

          run_test! do |response|
            expect(response.body).to eq(registration_error_json)
          end
        end

        response '403', 'PASSING organizer cannot access registrations for comps they arent organizing - single comp auth' do
          registration_error_json = { error: ErrorCodes::USER_INSUFFICIENT_PERMISSIONS }.to_json
          let!(:competition_id) { @attending_registrations_only }
          let(:'Authorization') { @organizer_token }

          run_test! do |response|
            expect(response.body).to eq(registration_error_json)
          end
        end

        response '403', 'PASSING organizer cannot access registrations for comps they arent organizing - multi comp auth' do
          registration_error_json = { error: ErrorCodes::USER_INSUFFICIENT_PERMISSIONS }.to_json
          let!(:competition_id) { @registrations_exist_comp_500 }
          let(:'Authorization') { @multi_comp_organizer_token }

          run_test! do |response|
            expect(response.body).to eq(registration_error_json)
          end
        end
      end
    end
  end
end
