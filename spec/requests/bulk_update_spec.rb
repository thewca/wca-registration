# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'v1 Registrations API', type: :request do
  path '/api/v1/bulk_update' do
    patch 'Update multiple registrations at once' do
      security [Bearer: {}]
      consumes 'application/json'
      parameter name: :bulk_update, in: :body

      response '200', 'organizer submits single update' do
        registration = FactoryBot.create(:registration)
        bulk_update_request = FactoryBot.build(:bulk_update_request, user_ids: [registration[:user_id]])

        let(:bulk_update) { bulk_update_request }
        let(:Authorization) { bulk_update[:jwt_token] }

        run_test!
      end
    end
  end
end
