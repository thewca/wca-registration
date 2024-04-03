# frozen_string_literal: true

require 'rails_helper'

describe RegistrationController do
  describe '#update' do
    # NOTE: This code only needs to run once before the assertions, but before(:create) doesnt work because `request` defined then
    before do
      @competition = FactoryBot.build(:competition)
      stub_request(:get, comp_api_url(@competition['id'])).to_return(status: 200, body: @competition.to_json)

      @registration = FactoryBot.create(:registration)

      update_request = FactoryBot.build(:update_request, user_id: @registration[:user_id], guests: 2, competing: { 'status' => 'cancelled' })

      request.headers['Authorization'] = update_request['jwt_token']
      patch :update, params: update_request, as: :json

      @response = response
      @body = JSON.parse(response.body)
      @updated_registration = Registration.find("#{@competition['id']}-#{@registration[:user_id]}")
    end

    it 'returns the expected response code' do
      expect(@response.code).to eq('200')
    end

    it 'returns a registration with the updated amount of guests' do
      expect(@body['registration']['guests']).to eq(2)
    end

    it 'returns a registration with the updated of guests' do
      expect(@body['registration']['competing']['registration_status']).to eq('cancelled')
    end

    it 'change in guests was persisted to database' do
      expect(@updated_registration.guests).to eq(2)
    end

    it 'change in status persisted to database' do
      expect(@updated_registration.competing_status).to eq('cancelled')
    end

    it 'registration history to be written' do
      expect(@updated_registration.history.entries.length).to eq(1)
    end

    it 'registration history contains the correct changes' do
      expect(@updated_registration.history.entries[0].changed_attributes['status']).to eq('cancelled')
      expect(@updated_registration.history.entries[0].changed_attributes['guests']).to eq(2)
      expect(@updated_registration.history.entries[0].action).to eq('Competitor delete')
    end
  end

  describe '#bulk_update' do
    # TODO: Consider refactor into separate contexts with one expect() per it-block
    it 'returns a 422 if there are validation errors' do
      registration = FactoryBot.create(:registration)
      update = FactoryBot.build(:update_request, user_id: registration[:user_id])
      registration2 = FactoryBot.create(:registration)
      update2 = FactoryBot.build(:update_request, user_id: registration2[:user_id], competing: { 'status' => 'invalid_status' })
      registration3 = FactoryBot.create(:registration)
      update3 = FactoryBot.build(:update_request, user_id: registration3[:user_id])

      competition = FactoryBot.build(:competition, mock_competition: true)
      stub_request(:get, comp_api_url(competition['id'])).to_return(status: 200, body: competition.to_json)

      updates = [update, update2, update3]
      bulk_update_request = FactoryBot.build(:bulk_update_request, requests: updates)

      request.headers['Authorization'] = bulk_update_request['jwt_token']
      patch :bulk_update, params: bulk_update_request, as: :json
      expect(response.code).to eq('422')
    end

    it 'if any validations fail, no updates are processed' do
      registration = FactoryBot.create(:registration)
      update = FactoryBot.build(:update_request, user_id: registration[:user_id])
      registration2 = FactoryBot.create(:registration)
      update2 = FactoryBot.build(:update_request, user_id: registration2[:user_id], competing: { 'status' => 'invalid_status' })
      registration3 = FactoryBot.create(:registration)
      update3 = FactoryBot.build(:update_request, user_id: registration3[:user_id])

      competition = FactoryBot.build(:competition, mock_competition: true)
      stub_request(:get, comp_api_url(competition['id'])).to_return(status: 200, body: competition.to_json)

      updates = [update, update2, update3]
      bulk_update_request = FactoryBot.build(:bulk_update_request, requests: updates)

      request.headers['Authorization'] = bulk_update_request['jwt_token']
      patch :bulk_update, params: bulk_update_request, as: :json

      updated_registration = Registration.find("#{competition['id']}-#{registration[:user_id]}")
      expect(updated_registration.competing_status).to eq('incoming')

      updated_registration = Registration.find("#{competition['id']}-#{registration3[:user_id]}")
      expect(updated_registration.competing_status).to eq('incoming')
    end

    it 'returns 200 and an array of registration objects' do
      registration = FactoryBot.create(:registration)
      update = FactoryBot.build(:update_request, user_id: registration[:user_id], competing: { 'status' => 'accepted' })
      registration2 = FactoryBot.create(:registration)
      update2 = FactoryBot.build(:update_request, user_id: registration2[:user_id], competing: { 'event_ids' => ['333', '444'] })
      registration3 = FactoryBot.create(:registration)
      update3 = FactoryBot.build(:update_request, user_id: registration3[:user_id], competing: { 'comment' => 'test comment update' })

      competition = FactoryBot.build(:competition, mock_competition: true)
      stub_request(:get, comp_api_url(competition['id'])).to_return(status: 200, body: competition.to_json)

      updates = [update, update2, update3]
      bulk_update_request = FactoryBot.build(:bulk_update_request, requests: updates)

      request.headers['Authorization'] = bulk_update_request['jwt_token']
      patch :bulk_update, params: bulk_update_request, as: :json
      expect(response.code).to eq('200')

      body = JSON.parse(response.body)['updated_registrations']

      expect(body[registration[:user_id].to_s]['competing']['registration_status']).to eq('accepted')
      expect(body[registration3[:user_id].to_s]['competing']['comment']).to eq('test comment update')
    end

    it 'updates the database as expected' do
      registration = FactoryBot.create(:registration)
      update = FactoryBot.build(:update_request, user_id: registration[:user_id], competing: { 'status' => 'accepted' })
      registration2 = FactoryBot.create(:registration)
      update2 = FactoryBot.build(:update_request, user_id: registration2[:user_id], competing: { 'event_ids' => ['333', '444'] })
      registration3 = FactoryBot.create(:registration)
      update3 = FactoryBot.build(:update_request, user_id: registration3[:user_id], competing: { 'comment' => 'test comment update' })

      competition = FactoryBot.build(:competition, mock_competition: true)
      stub_request(:get, comp_api_url(competition['id'])).to_return(status: 200, body: competition.to_json)

      updates = [update, update2, update3]
      bulk_update_request = FactoryBot.build(:bulk_update_request, requests: updates)

      request.headers['Authorization'] = bulk_update_request['jwt_token']
      patch :bulk_update, params: bulk_update_request, as: :json
      expect(response.code).to eq('200')

      updated_registration = Registration.find("#{competition['id']}-#{registration[:user_id]}")
      expect(updated_registration.competing_status).to eq('accepted')

      updated_registration3 = Registration.find("#{competition['id']}-#{registration3[:user_id]}")
      expect(updated_registration3.competing_comment).to eq('test comment update')
    end

    it 'admin submits a bulk update containing 1 update' do
      registration = FactoryBot.create(:registration)
      bulk_update_request = FactoryBot.build(:bulk_update_request, user_ids: [registration[:user_id]])

      competition = FactoryBot.build(:competition, mock_competition: true)
      stub_request(:get, comp_api_url(competition['id'])).to_return(status: 200, body: competition.to_json)

      request.headers['Authorization'] = bulk_update_request['jwt_token']
      patch :bulk_update, params: bulk_update_request, as: :json
      expect(response.code).to eq('200')
    end

    it 'returns 422 if blank json submitted' do
      registration = FactoryBot.create(:registration)
      bulk_update_request = FactoryBot.build(:bulk_update_request, user_ids: [registration[:user_id]])

      competition = FactoryBot.build(:competition, mock_competition: true)
      stub_request(:get, comp_api_url(competition['id'])).to_return(status: 200, body: competition.to_json)

      request.headers['Authorization'] = bulk_update_request['jwt_token']
      patch :bulk_update, params: {}, as: :json
      expect(response.code).to eq('422')
    end
  end
end
