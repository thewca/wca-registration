# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/jwt_token_generator'

describe TestController do
  describe '#test_reset.test_env' do
    it 'route is available when RAILS_ENV is test' do
      jwt_token = fetch_jwt_token('1306')
      request.headers['Authorization'] = jwt_token
      post :reset
      expect(response).to have_http_status(200)
    end

    it 'resets the database when called' do
      jwt_token = fetch_jwt_token('1306')
      FactoryBot.create_list(:registration, 3, registration_status: 'accepted')
      expect(Registration.all.count).to eq(3)

      request.headers['Authorization'] = jwt_token
      post :reset
      expect(Registration.all.count).to eq(0)
    end
  end

  # Done in a separate describe because that's what our `around` wrapper requires
  describe '#test_reset.prod_env' do
    around(:each) do |example|
      original_env = Rails.env
      Rails.env = 'production'

      example.run

      Rails.env = original_env
    end

    it 'controller rejects request when RAILS_ENV is production' do
      jwt_token = fetch_jwt_token('1306')
      request.headers['Authorization'] = jwt_token
      post :reset

      expect(response).to have_http_status(403)
    end
  end
end
