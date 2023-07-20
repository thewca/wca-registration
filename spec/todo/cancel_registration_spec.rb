# frozen_string_literal: true

require 'swagger_helper'
require_relative '../../app/helpers/error_codes'

RSpec.describe 'v1 Registrations API', type: :request do
  include Helpers::RegistrationHelper

  path '/api/v1/registrations/{competition_id}/{user_id}' do
    patch 'update or cancel an attendee registration' do
      parameter name: :competition_id, in: :path, type: :string, required: true
      parameter name: :user_id, in: :path, type: :string, required: true
      parameter name: :update, in: :body, required: true

      produces 'application/json'

      context 'SUCCESS: registration cancellations' do
        include_context 'PATCH payloads'
        include_context 'database seed'

        response '202', 'cancel non-cancelled registration' do
          # it_behaves_like 'cancel registration successfully', @cancellation, @competition_id, @user_id_816
          # it_behaves_like 'cancel registration successfully', @double_cancellation, @competition_id, @user_id_823
        end
      end

      context 'FAIL: registration cancellations' do
        include_context 'PATCH payloads'
        include_context 'database seed'

        response '400', 'cancel on lane that doesn\'t exist' do
          let!(:payload) { @cancel_wrong_lane }
          let!(:competition_id) { @competition_id }
          let!(:user_id) { @user_id_823 }
          # registration_error_json = { error: COMPETITION_INVALID_LANE_ACCESSED }.to_json

          run_test! do |reponse|
            expect(response.body).to eq(registration_error_json)
          end
        end
      end

      # context 'SUCCESS: registration updates' do
      # end
    end
  end
end
