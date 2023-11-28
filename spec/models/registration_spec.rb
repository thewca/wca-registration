# frozen_string_literal: true

require 'rails_helper'

describe Registration do
  describe 'validations#is_competing_consistency' do
    it 'passes if is_competing is true and status is accepted' do
      registration = FactoryBot.build(:registration, registration_status: 'accepted', is_competing: true)

      expect(registration).to be_valid
    end

    it 'adds an error if is_competing is true and status is not accepted' do
      registration = FactoryBot.build(:registration, registration_status: 'pending', is_competing: true)

      expect(registration).not_to be_valid
      expect(registration.errors[:is_competing]).to include('cant be true unless competing_status is accepted')
    end
  end

  describe '#update_competing_lane!' do
    it 'given accepted status, it changes the users status to accepted' do
      registration = FactoryBot.create(:registration, registration_status: 'pending')
      registration.update_competing_lane!({ status: 'accepted' })
      expect(registration.competing_status).to eq('accepted')
    end

    it 'given accepted status, it sets is_competing to true' do
      registration = FactoryBot.create(:registration, registration_status: 'pending')
      registration.update_competing_lane!({ status: 'accepted' })
      expect(registration.is_competing).to eq(true)
    end

    it 'accepted given cancelled, it sets is_competing to false' do
      registration = FactoryBot.create(:registration, registration_status: 'accepted')
      registration.update_competing_lane!({ status: 'cancelled' })
      expect(registration.is_competing).to eq(false)
    end

    it 'accepted given pending, it sets is_competing to false' do
      registration = FactoryBot.create(:registration, registration_status: 'accepted')
      registration.update_competing_lane!({ status: 'pending' })
      expect(registration.is_competing).to eq(false)
    end

    it 'accepted given waiting_list, it sets is_competing to false' do
      registration = FactoryBot.create(:registration, registration_status: 'accepted')
      registration.update_competing_lane!({ status: 'waiting_list' })
      expect(registration.is_competing).to eq(false)
    end
  end

  describe '#accepted_competitors' do
    it 'returns the number of accepted competitors only for a specific competition' do
      target_comp = 'TargetCompId'
      FactoryBot.create_list(:registration, 3, registration_status: 'accepted')
      FactoryBot.create_list(:registration, 3, registration_status: 'accepted', competition_id: target_comp)

      comp_registration_count = Registration.accepted_competitors(target_comp)

      expect(comp_registration_count).to eq(3)
    end

    it 'returns only competitors marked as is_competing' do
      target_comp = 'TargetCompId'
      FactoryBot.create_list(:registration, 3, registration_status: 'accepted')
      FactoryBot.create_list(:registration, 3, registration_status: 'accepted', competition_id: target_comp)
      FactoryBot.create_list(:registration, 3, registration_status: 'cancelled', competition_id: target_comp)

      comp_registration_count = Registration.accepted_competitors(target_comp)

      expect(comp_registration_count).to eq(3)
    end
  end

  describe '#set_is_competing' do
    it 'persists a true state to the database' do
      registration = FactoryBot.create(:registration, registration_status: 'accepted')
      expect(Registration.find(registration.attendee_id).is_competing).to eq(true)
    end

    it 'persists a false state to the database' do
      registration = FactoryBot.create(:registration, registration_status: 'pending')
      expect(Registration.find(registration.attendee_id).is_competing).to eq(nil)
    end
  end
end
