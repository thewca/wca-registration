# frozen_string_literal: true

require 'rails_helper'

describe Registration do
  describe 'validations#competing_status_consistency' do
    it 'passes if competing_status and competing lane status match' do
      registration = FactoryBot.build(:registration, registration_status: 'accepted')

      expect(registration).to be_valid
    end

    it 'incorrect competing status get corrected when validation is run' do
      registration = FactoryBot.build(:registration, registration_status: 'pending')
      registration.competing_status = 'accepted'

      expect(registration).to be_valid
    end
  end

  describe '#update_competing_lane!' do
    it 'given accepted status, it changes the users status to accepted' do
      registration = FactoryBot.create(:registration, registration_status: 'pending')
      registration.update_competing_lane!({ status: 'accepted' })
      expect(registration.competing_status).to eq('accepted')
    end

    it 'accepted given cancelled, it sets competing_status accordingly' do
      registration = FactoryBot.create(:registration, registration_status: 'accepted')
      registration.update_competing_lane!({ status: 'cancelled' })
      expect(registration.competing_status).to eq('cancelled')
    end

    it 'accepted given pending, it sets competing_status accordingly' do
      registration = FactoryBot.create(:registration, registration_status: 'accepted')
      registration.update_competing_lane!({ status: 'pending' })
      expect(registration.competing_status).to eq('pending')
    end

    it 'accepted given waiting_list, it sets competing_status' do
      registration = FactoryBot.create(:registration, registration_status: 'accepted')
      registration.update_competing_lane!({ status: 'waiting_list' })
      expect(registration.competing_status).to eq('waiting_list')
    end
  end

  describe '#update_competing_lane!.waiting_list' do
    describe '#waiting_list.add_to_waiting_list' do
      it 'first competitor in the waiting list gets set to position 1' do
        registration = FactoryBot.create(:registration, registration_status: 'pending')
        registration.update_competing_lane!({ status: 'waiting_list' })
        expect(registration.competing_waiting_list_position).to eq(1)
      end

      it 'second competitor gets set to position 2' do
        FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 1)
        registration = FactoryBot.create(:registration, registration_status: 'pending')
        registration.update_competing_lane!({ status: 'waiting_list' })
        expect(registration.competing_waiting_list_position).to eq(2)
      end
    end

    describe '#waiting_list.move_within_waiting_list' do
      # TODO
    end

    describe '#waiting_list.accept_from_waiting_list' do
      it 'when accepted, waiting_list_position gets set to nil' do
        registration = FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 1)
        # registration.update_competing_lane!({ status: 'accepted' })
        expect(registration.competing_waiting_list_position).to eq(3)
      end

      it 'if waiting list is empty, new min/max should be nil' do
        expect(true).to eq(false)
      end

      it 'if waiting list isnt empty, new min should be one greater than the accepted registrations old waiting list position' do
        expect(true).to eq(false)
      end
    end

    describe '#waiting_list.remove_from_waiting_list' do
      # TODO
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
      expect(Registration.find(registration.attendee_id).competing_status).to eq('accepted')
    end

    it 'persists a false state to the database' do
      registration = FactoryBot.create(:registration, registration_status: 'pending')
      expect(Registration.find(registration.attendee_id).competing_status).to eq('pending')
    end
  end
end
