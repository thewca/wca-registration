# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'v1 Registrations API', type: :request do
  include Helpers::RegistrationHelper

  path '/api/v1/register' do
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
    end
  end
end
