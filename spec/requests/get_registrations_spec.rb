# frozen_string_literal: true

require 'swagger_helper'
require_relative '../support/registration_spec_helper'
require_relative '../../app/helpers/error_codes'

# TODO: Add case where registration for the competition hasn't opened yet, but the competition exists - should return empty list
# FINN TODO: Why doesn't list_admin call competition API? Should it?
# TODO: Check Swaggerized output
# TODO: Brainstorm other tests that could be included
RSpec.describe 'v1 Registrations API', type: :request do
  include Helpers::RegistrationHelper

  path '/api/v1/registrations/{competition_id}' do
    get 'Public: list registrations for a given competition_id' do
      parameter name: :competition_id, in: :path, type: :string, required: true
      produces 'application/json'

      context '-> success responses' do
        include_context 'competition information'
        include_context 'database seed'

        response '200', '-> PASSING request and response conform to schema' do
          schema type: :array, items: { '$ref' => '#/components/schemas/registration' }

          let!(:competition_id) { @attending_registrations_only }

          run_test! do |response|
            body = JSON.parse(response.body)
            expect(body.length).to eq(4)
          end
        end

        response '200', ' -> PASSING only returns attending registrations' do # waiting_list are being counted as is_attending - not sure how this is set? maybe in the model logic?
          let!(:competition_id) { @includes_non_attending_registrations }

          run_test! do |response|
            body = JSON.parse(response.body)
            expect(body.length).to eq(2)
          end
        end

        response '200', ' -> PASSING Valid competition_id but no registrations for it' do
          let!(:competition_id) { @empty_comp }

          run_test! do |response|
            body = JSON.parse(response.body)
            expect(body).to eq([])
          end
        end

        context 'Competition service down (500) but registrations exist' do
          response '200', ' -> PASSING comp service down but registrations exist' do
            let!(:competition_id) { @registrations_exist_comp_500 }

            run_test! do |response|
              body = JSON.parse(response.body)
              expect(body.length).to eq(3)
            end
          end
        end

        context 'Competition service down (502) but registrations exist' do
          response '200', ' -> PASSING comp service down but registrations exist' do
            let!(:competition_id) { @registrations_exist_comp_502 }

            run_test! do |response|
              body = JSON.parse(response.body)
              expect(body.length).to eq(2)
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

        response '200', ' -> PASSING request and response conform to schema' do
          schema type: :array, items: { '$ref' => '#/components/schemas/registrationAdmin' }

          let!(:competition_id) { @attending_registrations_only }
          let(:Authorization) { @admin_token }

          run_test! do |response|
            body = JSON.parse(response.body)
            expect(body.length).to eq(4)
          end
        end

        response '200', ' -> PASSING admin registration endpoint returns registrations in all states' do
          let!(:competition_id) { @includes_non_attending_registrations }
          let(:Authorization) { @admin_token }

          run_test! do |response|
            body = JSON.parse(response.body)
            expect(body.length).to eq(6)
          end
        end

        response '200', ' -> PASSING organizer can access admin list for their competition' do
          let!(:competition_id) { @includes_non_attending_registrations }
          let(:Authorization) { @organizer_token }

          run_test! do |response|
            body = JSON.parse(response.body)
            expect(body.length).to eq(6)
          end
        end

        context 'user has comp-specific auth for multiple comps' do
          response '200', ' -> PASSING organizer has access to comp 1' do
            let!(:competition_id) { @includes_non_attending_registrations }
            let(:Authorization) { @multi_comp_organizer_token }

            run_test! do |response|
              body = JSON.parse(response.body)
              expect(body.length).to eq(6)
            end
          end

          response '200', ' -> PASSING organizer has access to comp 2' do
            let!(:competition_id) { @attending_registrations_only }
            let(:Authorization) { @multi_comp_organizer_token }

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

        response '401', ' -> PASSING Attending user cannot get admin registration list' do
          schema '$ref' => '#/components/schemas/error_response'
          registration_error_json = { error: ErrorCodes::USER_INSUFFICIENT_PERMISSIONS }.to_json
          let!(:competition_id) { @attending_registrations_only }
          let(:Authorization) { @jwt_817 }

          run_test! do |response|
            expect(response.body).to eq(registration_error_json)
          end
        end

        response '401', ' -> PASSING organizer cannot access registrations for comps they arent organizing - single comp auth' do
          registration_error_json = { error: ErrorCodes::USER_INSUFFICIENT_PERMISSIONS }.to_json
          let!(:competition_id) { @attending_registrations_only }
          let(:Authorization) { @organizer_token }

          run_test! do |response|
            expect(response.body).to eq(registration_error_json)
          end
        end

        response '401', ' -> PASSING organizer cannot access registrations for comps they arent organizing - multi comp auth' do
          registration_error_json = { error: ErrorCodes::USER_INSUFFICIENT_PERMISSIONS }.to_json
          let!(:competition_id) { @registrations_exist_comp_500 }
          let(:Authorization) { @multi_comp_organizer_token }

          run_test! do |response|
            expect(response.body).to eq(registration_error_json)
          end
        end
      end
    end
  end
end
