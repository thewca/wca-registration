# frozen_string_literal: true

require 'swagger_helper'
require_relative '../support/registration_spec_helper'

RSpec.describe 'v1 Registrations API', type: :request do
  include Helpers::RegistrationHelper

  path '/api/v1/attendees/{attendee_id}' do
    get 'Retrieve attendee registration' do
      parameter name: :attendee_id, in: :path, type: :string, required: true
      produces 'application/json'

      context 'success get attendee registration' do
        existing_attendee = 'CubingZANationalChampionship2023-158816'

        response '200', 'validate endpoint and schema' do
          schema '$ref' => '#/components/schemas/registration'

          let!(:attendee_id) { existing_attendee }

          run_test!
        end

        response '200', 'check that registration returned matches expected registration' do
          include_context 'registration_data'

          let!(:attendee_id) { existing_attendee }

          run_test! do |response|
            # TODO: This should use a custom-written comparison script
            expect(response.body).to eq(basic_registration)
          end
        end
      end

      context 'fail get attendee registration' do
        response '404', 'attendee_id doesnt exist' do
          let!(:attendee_id) { 'InvalidAttendeeID' }

          run_test! do |response|
            expect(response.body).to eq({ error: "No registration found for attendee_id: #{attendee_id}." }.to_json)
          end
        end
      end
    end
  end
end
