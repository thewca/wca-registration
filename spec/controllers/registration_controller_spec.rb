# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/qualification_results_faker'

describe RegistrationController do
  describe '#create' do
    before do
      @registration_request = FactoryBot.build(:registration_request)
      stub_request(:get, UserApi.permissions_path(@registration_request['user_id'])).to_return(
        status: 200,
        body: FactoryBot.build(:permissions).to_json,
        headers: { 'Content-Type' => 'application/json' },
      )
      stub_request(:post, EmailApi.registration_email_path).to_return(status: 200, body: { emails_sent: 1 }.to_json)
    end

    it 'successfully creates a registration' do
      @competition = FactoryBot.build(:competition)
      stub_request(:get, CompetitionApi.url(@competition['id'])).to_return(
        status: 200,
        body: @competition.except('qualifications').to_json,
        headers: { 'Content-Type' => 'application/json' },
      )

      request.headers['Authorization'] = @registration_request['jwt_token']
      post :create, params: @registration_request, as: :json
      sleep 1 # Give the queue time to work off the registration - perhaps this should be a queue length query instead?

      expect(response.code).to eq('202')

      created_registration = Registration.find("#{@competition['id']}-#{@registration_request['user_id']}")
      expect(created_registration.event_ids).to eq(@registration_request['competing']['event_ids'])
    end

    context 'with qualification' do
      before do
        @competition = FactoryBot.build(:competition, :has_qualifications)
        stub_json(CompetitionApi.url(@competition['id']), 200, @competition.except('qualifications'))
        stub_json(CompetitionApi.url("#{@competition['id']}/qualifications"), 200, @competition['qualifications'])
      end

      it 'registration succeeds when qualifications are met' do
        stub_json(UserApi.competitor_qualifications_path(@registration_request['user_id']), 200, QualificationResultsFaker.new.qualification_results)

        request.headers['Authorization'] = @registration_request['jwt_token']
        post :create, params: @registration_request, as: :json
        sleep 0.1 # Give the queue time to work off the registration - perhaps this should be a queue length query instead?

        created_registration = Registration.find("#{@competition['id']}-#{@registration_request['user_id']}")

        expect(response.code).to eq('202')
        expect(created_registration.event_ids).to eq(@registration_request['competing']['event_ids'])
      end

      it 'registration fails when qualifications not met' do
        stub_json(UserApi.competitor_qualifications_path(@registration_request['user_id']), 200, [])

        request.headers['Authorization'] = @registration_request['jwt_token']
        post :create, params: @registration_request, as: :json
        sleep 0.1 # Give the queue time to work off the registration - perhaps this should be a queue length query instead?

        expect(response.code).to eq('422')
        expect(response.body).to eq({ error: -4012 }.to_json)
        expect { Registration.find("#{@competition['id']}-#{@registration_request['user_id']}") }.to raise_error(Dynamoid::Errors::RecordNotFound)
      end
    end
  end

  describe '#update' do
    # NOTE: This code only needs to run once before the assertions, but before(:create) doesnt work because `request` defined then
    before do
      @competition = FactoryBot.build(:competition)
      stub_json(CompetitionApi.url(@competition['id']), 200, @competition.except('qualifications'))
      stub_request(:post, EmailApi.registration_email_path).to_return(status: 200, body: { emails_sent: 1 }.to_json)

      @registration = FactoryBot.create(:registration)

      update_request = FactoryBot.build(:update_request, user_id: @registration[:user_id], guests: 2, competing: { 'status' => 'cancelled' })
      stub_request(:get, UserApi.permissions_path(update_request['submitted_by'])).to_return(
        status: 200,
        body: FactoryBot.build(:permissions_response, organized_competitions: [@competition['id']]).to_json,
        headers: { content_type: 'application/json' },
      )

      request.headers['Authorization'] = update_request['jwt_token']
      patch :update, params: update_request, as: :json

      @response = response

      @body = response.parsed_body
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
    before do
      @competition = FactoryBot.build(:competition, mock_competition: true)
      stub_json(CompetitionApi.url(@competition['id']), 200, @competition.except('qualifications'))
      stub_request(:post, EmailApi.registration_email_path).to_return(status: 200, body: { emails_sent: 1 }.to_json)

      stub_request(:get, UserApi.permissions_path(1400)).to_return(
        status: 200,
        body: FactoryBot.build(:permissions_response, :admin).to_json,
        headers: { content_type: 'application/json' },
      )
    end

    describe 'waiting list bulk updates' do
      it 'accepts competitors from the waiting list' do
        registration = FactoryBot.create(:registration, :waiting_list)
        update = FactoryBot.build(:update_request, user_id: registration[:user_id], competing: { 'status' => 'accepted' })
        registration2 = FactoryBot.create(:registration, :waiting_list)
        update2 = FactoryBot.build(:update_request, user_id: registration2[:user_id], competing: { 'status' => 'accepted' })
        registration3 = FactoryBot.create(:registration, :waiting_list)
        update3 = FactoryBot.build(:update_request, user_id: registration3[:user_id], competing: { 'status' => 'accepted' })

        waiting_list = FactoryBot.create(:waiting_list, entries: [registration.user_id, registration2.user_id, registration3.user_id])

        updates = [update, update2, update3]
        bulk_update_request = FactoryBot.build(:bulk_update_request, requests: updates)

        request.headers['Authorization'] = bulk_update_request['jwt_token']
        patch :bulk_update, params: bulk_update_request, as: :json

        expect(response.code).to eq('200')

        updated_registration = Registration.find("#{@competition['id']}-#{registration[:user_id]}")
        expect(updated_registration.competing_status).to eq('accepted')
        updated_registration2 = Registration.find("#{@competition['id']}-#{registration2[:user_id]}")
        expect(updated_registration2.competing_status).to eq('accepted')
        updated_registration3 = Registration.find("#{@competition['id']}-#{registration3[:user_id]}")
        expect(updated_registration3.competing_status).to eq('accepted')

        expect(waiting_list.reload.entries.empty?).to eq(true)
      end
    end

    it 'returns a 422 if there are validation errors' do
      registration = FactoryBot.create(:registration)
      update = FactoryBot.build(:update_request, user_id: registration[:user_id])
      registration2 = FactoryBot.create(:registration)
      update2 = FactoryBot.build(:update_request, user_id: registration2[:user_id], competing: { 'status' => 'invalid_status' })
      registration3 = FactoryBot.create(:registration)
      update3 = FactoryBot.build(:update_request, user_id: registration3[:user_id])

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

      updates = [update, update2, update3]
      bulk_update_request = FactoryBot.build(:bulk_update_request, requests: updates)

      request.headers['Authorization'] = bulk_update_request['jwt_token']
      patch :bulk_update, params: bulk_update_request, as: :json

      updated_registration = Registration.find("#{@competition['id']}-#{registration[:user_id]}")
      expect(updated_registration.competing_status).to eq('incoming')

      updated_registration = Registration.find("#{@competition['id']}-#{registration3[:user_id]}")
      expect(updated_registration.competing_status).to eq('incoming')
    end

    it 'returns 200 and an array of registration objects' do
      registration = FactoryBot.create(:registration)
      update = FactoryBot.build(:update_request, user_id: registration[:user_id], competing: { 'status' => 'accepted' })
      registration2 = FactoryBot.create(:registration)
      update2 = FactoryBot.build(:update_request, user_id: registration2[:user_id], competing: { 'event_ids' => ['333', '444'] })
      registration3 = FactoryBot.create(:registration)
      update3 = FactoryBot.build(:update_request, user_id: registration3[:user_id], competing: { 'comment' => 'test comment update' })

      updates = [update, update2, update3]
      bulk_update_request = FactoryBot.build(:bulk_update_request, requests: updates)

      request.headers['Authorization'] = bulk_update_request['jwt_token']
      patch :bulk_update, params: bulk_update_request, as: :json
      expect(response.code).to eq('200')

      body = response.parsed_body['updated_registrations']

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

      updates = [update, update2, update3]
      bulk_update_request = FactoryBot.build(:bulk_update_request, requests: updates)

      request.headers['Authorization'] = bulk_update_request['jwt_token']
      patch :bulk_update, params: bulk_update_request, as: :json
      expect(response.code).to eq('200')

      updated_registration = Registration.find("#{@competition['id']}-#{registration[:user_id]}")
      expect(updated_registration.competing_status).to eq('accepted')

      updated_registration3 = Registration.find("#{@competition['id']}-#{registration3[:user_id]}")
      expect(updated_registration3.competing_comment).to eq('test comment update')
    end

    it 'admin submits a bulk update containing 1 update' do
      registration = FactoryBot.create(:registration)
      bulk_update_request = FactoryBot.build(:bulk_update_request, user_ids: [registration[:user_id]])

      request.headers['Authorization'] = bulk_update_request['jwt_token']
      patch :bulk_update, params: bulk_update_request, as: :json
      expect(response.code).to eq('200')
    end

    it 'returns 400 if blank json submitted' do
      registration = FactoryBot.create(:registration)
      bulk_update_request = FactoryBot.build(:bulk_update_request, user_ids: [registration[:user_id]])

      request.headers['Authorization'] = bulk_update_request['jwt_token']
      patch :bulk_update, params: {}, as: :json
      expect(response.code).to eq('400')
    end
  end

  describe '#list_admin', :tag do
    before do
      @competition = FactoryBot.build(:competition)
      stub_json(CompetitionApi.url(@competition['id']), 200, @competition.except('qualifications'))

      @requesting_user_id = 1400
      stub_request(:get, UserApi.permissions_path(@requesting_user_id)).to_return(
        status: 200,
        body: FactoryBot.build(:permissions_response, organized_competitions: [@competition['id']]).to_json,
        headers: { 'Content-Type' => 'application/json' },
      )
    end

    it 'returns single registration' do
      registration = FactoryBot.create(:registration)
      stub_pii([registration[:user_id]])

      request.headers['Authorization'] = fetch_jwt_token(@requesting_user_id) 
      get :list_admin, params: { competition_id: @competition['id'] }

      expect(response.code).to eq('200')

      body = response.parsed_body
      expect(body.count).to eq(1)
      expect(body.first['user_id']).to eq(registration[:user_id])
      expect(body.first.dig('competing', 'registration_status')).to eq(registration.competing_status)
      expect(body.first.dig('competing', 'waiting_list_position')).to eq(nil)
    end

    it 'returns multiple registrations' do

      reg = FactoryBot.create(:registration, :accepted)
      reg2 = FactoryBot.create(:registration, :accepted)
      reg3 = FactoryBot.create(:registration, :accepted)

      reg4 = FactoryBot.create(:registration, :waiting_list)
      reg5 = FactoryBot.create(:registration, :waiting_list)
      reg6 = FactoryBot.create(:registration, :waiting_list)

      waiting_list = FactoryBot.create(:waiting_list, entries: [reg4[:user_id], reg5[:user_id], reg6[:user_id]])

      user_ids = [reg[:user_id], reg2[:user_id], reg3[:user_id], reg4[:user_id], reg5[:user_id], reg6[:user_id]]
      stub_pii(user_ids)

      request.headers['Authorization'] = fetch_jwt_token(@requesting_user_id) 
      get :list_admin, params: { competition_id: @competition['id'] }

      expect(response.code).to eq('200')

      body = response.parsed_body
      expect(body.count).to eq(6)

      body.each do |data|
        expect(user_ids.include?(data['user_id'])).to eq(true)
        if data['user_id'] == reg[:user_id] || data['user_id'] == reg2[:user_id] ||data['user_id'] == reg3[:user_id] 
          expect(data.dig('competing', 'registration_status')).to eq('accepted')
          expect(data.dig('competing', 'waiting_list_position')).to eq(nil)
        elsif data['user_id'] == reg4[:user_id]
          expect(data.dig('competing', 'waiting_list_position')).to eq(1)
        elsif data['user_id'] == reg5[:user_id]
          expect(data.dig('competing', 'waiting_list_position')).to eq(2)
        elsif data['user_id'] == reg6[:user_id]
          expect(data.dig('competing', 'waiting_list_position')).to eq(3)
        end
      end
    end
  end
end
