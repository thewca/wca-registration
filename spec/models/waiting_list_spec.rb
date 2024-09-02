# frozen_string_literal: true

require 'rails_helper'

describe WaitingList do
  describe '#add_to_waiting_list' do
    before do
      @waiting_list = FactoryBot.create(:waiting_list)
    end

    it 'first competitor in the waiting list gets set to position 1' do
      registration = FactoryBot.create(:registration, registration_status: 'pending')
      registration.update_competing_lane!({ status: 'waiting_list' }, @waiting_list)
      expect(registration.waiting_list_position(@waiting_list)).to eq(1)
    end

    it 'second competitor gets set to position 2' do
      @waiting_list.add(FactoryBot.create(:registration, :waiting_list).user_id)
      registration = FactoryBot.create(:registration, registration_status: 'pending')
      registration.update_competing_lane!({ status: 'waiting_list' }, @waiting_list)
      expect(registration.waiting_list_position(@waiting_list)).to eq(2)
    end
  end

  describe '#waiting_list.move_within_waiting_list' do
    before do
      @waiting_list = FactoryBot.create(:waiting_list)

      @registration1 = FactoryBot.create(:registration, :waiting_list)
      @registration2 = FactoryBot.create(:registration, :waiting_list)
      @registration3 = FactoryBot.create(:registration, :waiting_list)
      @registration4 = FactoryBot.create(:registration, :waiting_list)
      @registration5 = FactoryBot.create(:registration, :waiting_list)

      @waiting_list.add(@registration1.user_id)
      @waiting_list.add(@registration2.user_id)
      @waiting_list.add(@registration3.user_id)
      @waiting_list.add(@registration4.user_id)
      @waiting_list.add(@registration5.user_id)
    end

    it 'can be moved forward in the list' do
      @waiting_list.move_to_position(@registration4.user_id, 2)

      expect(@registration1.waiting_list_position(@waiting_list)).to eq(1)
      expect(@registration2.waiting_list_position(@waiting_list)).to eq(3)
      expect(@registration3.waiting_list_position(@waiting_list)).to eq(4)
      expect(@registration4.waiting_list_position(@waiting_list)).to eq(2)
      expect(@registration5.waiting_list_position(@waiting_list)).to eq(5)
    end

    it 'can be moved backward in the list' do
      @waiting_list.move_to_position(@registration2.user_id, 5)

      expect(@registration1.waiting_list_position(@waiting_list)).to eq(1)
      expect(@registration2.waiting_list_position(@waiting_list)).to eq(5)
      expect(@registration3.waiting_list_position(@waiting_list)).to eq(2)
      expect(@registration4.waiting_list_position(@waiting_list)).to eq(3)
      expect(@registration5.waiting_list_position(@waiting_list)).to eq(4)
    end

    it 'can be moved to the first position in the list' do
      @waiting_list.move_to_position(@registration5.user_id, 1)

      expect(@registration1.waiting_list_position(@waiting_list)).to eq(2)
      expect(@registration2.waiting_list_position(@waiting_list)).to eq(3)
      expect(@registration3.waiting_list_position(@waiting_list)).to eq(4)
      expect(@registration4.waiting_list_position(@waiting_list)).to eq(5)
      expect(@registration5.waiting_list_position(@waiting_list)).to eq(1)
    end

    it 'nothing happens if you move an item to its current position' do
      @waiting_list.move_to_position(@registration3.user_id, 3)

      expect(@registration1.waiting_list_position(@waiting_list)).to eq(1)
      expect(@registration2.waiting_list_position(@waiting_list)).to eq(2)
      expect(@registration3.waiting_list_position(@waiting_list)).to eq(3)
      expect(@registration4.waiting_list_position(@waiting_list)).to eq(4)
      expect(@registration5.waiting_list_position(@waiting_list)).to eq(5)
    end

    it 'can be moved to the last position in the list' do
      @waiting_list.move_to_position(@registration2.user_id, 5)

      expect(@registration1.waiting_list_position(@waiting_list)).to eq(1)
      expect(@registration2.waiting_list_position(@waiting_list)).to eq(5)
      expect(@registration3.waiting_list_position(@waiting_list)).to eq(2)
      expect(@registration4.waiting_list_position(@waiting_list)).to eq(3)
      expect(@registration5.waiting_list_position(@waiting_list)).to eq(4)
    end

    it 'cant be moved to a position greater than the list length' do
      expect {
        @waiting_list.move_to_position(@registration2.user_id, 6)
      }.to raise_error(ArgumentError, 'Target position out of waiting list range')
    end

    it 'cant be moved to a negative position' do
      expect {
        @waiting_list.move_to_position(@registration2.user_id, -1)
      }.to raise_error(ArgumentError, 'Target position out of waiting list range')
    end

    it 'cant be moved to position 0' do
      expect {
        @waiting_list.move_to_position(@registration2.user_id, 0)
      }.to raise_error(ArgumentError, 'Target position out of waiting list range')
    end
  end
end
