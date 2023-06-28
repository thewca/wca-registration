# frozen_string_literal: true

require 'swagger_helper'
require_relative '../../../app/helpers/error_codes'

RSpec.describe 'v1 Registrations API', type: :request do
  include Helpers::RegistrationHelper

  # TODO: Update this to have commp id and user id specified in URL. Make sure that parameter is updated appropriately as well.
  # TODO: Check that the tests run
  path '/api/v1/registrations/' do
    patch 'update an attendee registration' do
      parameter name: :update, in: :body, required: true
      produces 'application/json'

      context 'SUCCESS: registration cancellations' do
        include_context 'PATCH payloads'
        include_context 'database seed'

        response '202', 'cancel non-cancelled registration' do
          it_behaves_like 'cancel registration successfully', @cancellation
          it_behaves_like 'cancel registration successfully', @double_cancellation
        end
      end

      context 'FAIL: registration cancellations' do
        include_context 'PATCH payloads'
        include_context 'database seed'

        response '400', 'cancel on lane that doesn\'t exist' do
          let (:payload) { @cancel_wrong_lane }
          registration_error_json = { error: COMPETITION_INVALID_LANE_ACCESSED }.to_json

          run_test! do |reponse|
            expect(response.body).to eq(registration_error_json)
          end
        end
      end
    end
  end
end
