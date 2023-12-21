# frozen_string_literal: true

require 'rails_helper'

describe RegistrationController do
  describe '#bulk_update' do
    it 'admin submits a bulk update with single update' do
      registration = FactoryBot.create(:registration)
      bulk_update_request = FactoryBot.build(:bulk_update_request, user_ids: [registration[:user_id]])

      request.headers['Authorization'] = bulk_update_request['jwt_token']
      patch :bulk_update, params: { bulk_update_request: bulk_update_request }, format: :json
      expect(response.code).to eq('200')
    end

    it 'single update has intended effect' do
      # competition_info = CompetitionInfo.new(FactoryBot.build(:competition))
      registration = FactoryBot.create(:registration)
      bulk_update_request = FactoryBot.build(:bulk_update_request, user_ids: [registration[:user_id]])

      request.headers['Authorization'] = bulk_update_request['jwt_token']
      patch :bulk_update, params: { bulk_update_request: bulk_update_request }, format: :json
    end

    it 'user cannot submit bulk update request' do
      expect(true).to eq(false)
    end

    it 'admin submits a bulk update with 3 updates' do
      expect(true).to eq(false)
    end

    it 'bulk update request returns ok if all updates succeed' do
      expect(true).to eq(false)
    end

    it 'returns a map of user_id:error_code for all validations that fail' do
      expect(true).to eq(false)
    end

    it 'if any validations fail, no updates are processed' do
      expect(true).to eq(false)
    end
  end
end
