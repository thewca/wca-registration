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
    before do
      @waiting_list = FactoryBot.create(:waiting_list)
    end

    it 'given accepted status, it changes the users status to accepted' do
      registration = FactoryBot.create(:registration, registration_status: 'pending')
      registration.update_competing_lane!({ status: 'accepted' }, @waiting_list)
      expect(registration.competing_status).to eq('accepted')
    end

    it 'accepted given cancelled, it sets competing_status accordingly' do
      registration = FactoryBot.create(:registration, registration_status: 'accepted')
      registration.update_competing_lane!({ status: 'cancelled' }, @waiting_list)
      expect(registration.competing_status).to eq('cancelled')
    end

    it 'accepted given pending, it sets competing_status accordingly' do
      registration = FactoryBot.create(:registration, registration_status: 'accepted')
      registration.update_competing_lane!({ status: 'pending' }, @waiting_list)
      expect(registration.competing_status).to eq('pending')
    end

    it 'accepted given waiting_list, it sets competing_status' do
      registration = FactoryBot.create(:registration, registration_status: 'accepted')
      registration.update_competing_lane!({ status: 'waiting_list' }, @waiting_list)
      expect(registration.competing_status).to eq('waiting_list')
    end
  end

  describe '#competing_waiting_list_position' do
    it '1st competitor is at position 1' do
      registration = FactoryBot.create(:registration, registration_status: 'waiting_list')
      waiting_list = FactoryBot.create(:waiting_list, entries: [registration.user_id])
      expect(registration.waiting_list_position(waiting_list)).to eq(1)
    end

    it '5th competitor is at position 5' do
      waiting_list = FactoryBot.create(:waiting_list, id: 'AnotherComp2024', populate: 4)
      registration = FactoryBot.create(:registration, registration_status: 'waiting_list')
      waiting_list.add(registration.user_id)

      expect(registration.waiting_list_position(waiting_list)).to eq(5)
    end
  end

  describe '#update_competing_lane!.waiting_list' do
    # TODO: Needs more logic to test whether the logic paths for update_waiting_list (status are same, not change in waiting list position, etc)

    before do
      @reg1 = FactoryBot.create(:registration, :waiting_list)
      @reg2 = FactoryBot.create(:registration, :waiting_list)
      @waiting_list = FactoryBot.create(:waiting_list, entries: [@reg1.user_id, @reg2.user_id])
    end

    describe '#waiting_list.accept' do
      it 'accept waiting list leader' do
        @reg1.update_competing_lane!({ status: 'accepted' }, @waiting_list)
        @waiting_list.reload

        expect(@reg1.competing_status).to eq('accepted')
        expect(@reg1.waiting_list_position(@waiting_list)).to eq(nil)
        expect(@reg2.waiting_list_position(@waiting_list)).to eq(1)
        expect(@waiting_list.entries.include?(@reg1.user_id)).to eq(false)
      end

      it 'can accept if not in leading position of waiting list' do
        stub_request(:post, EmailApi.waiting_list_leader_path).to_return(status: 200, body: { emails_sent: 1 }.to_json)

        @reg2.update_competing_lane!({ status: 'accepted' }, @waiting_list)
        @waiting_list.reload

        expect(@reg2.competing_status).to eq('accepted')
        expect(@reg1.waiting_list_position(@waiting_list)).to eq(1)
        expect(@waiting_list.entries.include?(@reg2.user_id)).to eq(false)
        expect(WebMock).to have_requested(:post, EmailApi.waiting_list_leader_path)
      end
    end

    describe '#waiting_list.remove' do
      it 'change from waiting_list to cancelled' do
        @reg1.update_competing_lane!({ status: 'cancelled' }, @waiting_list)
        @waiting_list.reload

        expect(@reg1.competing_status).to eq('cancelled')
        expect(@reg1.waiting_list_position(@waiting_list)).to eq(nil)
        expect(@reg2.waiting_list_position(@waiting_list)).to eq(1)
        expect(@waiting_list.entries.include?(@reg1.user_id)).to eq(false)
      end

      it 'change from waiting_list to pending' do
        @reg1.update_competing_lane!({ status: 'pending' }, @waiting_list)
        @waiting_list.reload

        expect(@reg1.competing_status).to eq('pending')
        expect(@reg1.waiting_list_position(@waiting_list)).to eq(nil)
        expect(@reg2.waiting_list_position(@waiting_list)).to eq(1)
        expect(@waiting_list.entries.include?(@reg1.user_id)).to eq(false)
      end
    end

    describe '#waiting_list.move' do
      it 'changing to waiting_list has no effect' do
        @reg1.update_competing_lane!({ status: 'waiting_list' }, @waiting_list)
        @waiting_list.reload

        expect(@reg1.competing_status).to eq('waiting_list')
        expect(@reg1.waiting_list_position(@waiting_list)).to eq(1)
        expect(@reg2.waiting_list_position(@waiting_list)).to eq(2)
        expect(@waiting_list.entries.include?(@reg1.user_id)).to eq(true)
      end

      it 'can reorder waiting list items' do
        @reg2.update_competing_lane!({ status: 'waiting_list', waiting_list_position: 1 }, @waiting_list)

        expect(@reg1.competing_status).to eq('waiting_list')
        expect(@reg1.waiting_list_position(@waiting_list)).to eq(2)
        expect(@reg2.waiting_list_position(@waiting_list)).to eq(1)
        expect(@waiting_list.entries.include?(@reg1.user_id)).to eq(true)
      end
    end
  end

  describe '#accepted_competitors' do
    it 'returns the number of accepted competitors only for a specific competition' do
      target_comp = 'TargetCompId'
      FactoryBot.create_list(:registration, 3, registration_status: 'accepted')
      FactoryBot.create_list(:registration, 3, registration_status: 'accepted', competition_id: target_comp)

      comp_registration_count = Registration.accepted_competitors_count(target_comp)

      expect(comp_registration_count).to eq(3)
    end

    it 'returns only competitors marked as is_competing' do
      target_comp = 'TargetCompId'
      FactoryBot.create_list(:registration, 3, registration_status: 'accepted')
      FactoryBot.create_list(:registration, 3, registration_status: 'accepted', competition_id: target_comp)
      FactoryBot.create_list(:registration, 3, registration_status: 'cancelled', competition_id: target_comp)

      comp_registration_count = Registration.accepted_competitors_count(target_comp)

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
