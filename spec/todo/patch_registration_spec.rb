# frozen_string_literal: true

require 'swagger_helper'
require_relative '../../app/helpers/error_codes'

RSpec.describe 'v1 Registrations API', type: :request do
  include Helpers::RegistrationHelper

  # TODO: Figure out why competiton_id isn't being included in ROUTE path, and fix it on cancel file too
  # TODO: What happens to existing registrations if the organisser wants to change currency or price of events that registrations already exist for? Is this allowed?
  # TODO: Should we still have last action information if we're going to have a separate logging system for registration changes?
  path '/api/v1/registrations/{competition_id}/{user_id}' do
    patch 'update or cancel an attendee registration' do
      parameter name: :competition_id, in: :path, type: :string, required: true
      parameter name: :user_id, in: :path, type: :string, required: true
      parameter name: :update, in: :body, required: true

      produces 'application/json'

      context 'SUCCESS: Registration update base cases' do
        include_context 'PATCH payloads'
        include_context 'database seed'

        response '200', 'add a new event' do
          let!(:payload) { @add_444 }
          let!(:competition_id) { @competition_id }
          let!(:user_id) { @user_id_816 }

          run_test! do
            registration = Registrations.find('CubingZANationalChampionship2023-158816')

            reg_for_444 = false

            # NOTE: Breaks if we have more than 1 lane
            events = registration[:lanes][0].lane_details["event_details"]
            events.each do |event|
              if event["event_id"] == "444"
                reg_for_444 = true
              end
            end

            expect(reg_for_444).to eq(true)
          end
        end
      end
    end
  end
end
