# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'v1 Registrations API', type: :request do
  include Helpers::RegistrationHelper

  path '/api/v1/attendee' do
    patch 'update an attendee registration' do
      parameters name: :update, in: :body, required: true

      context 'registration cancellations' do
        response '200', 'cancel non-cancelled registration' do
          # Set up an existing registration in the database
          include_context 'Database seed'

        expect Registrations.find("")
          # let(:update) { update }

          # run_test! do |response|
          #   body = JSON.parse(response.body)
          #   expect(body).to eq([])

        end

      end
    end
  end
end
