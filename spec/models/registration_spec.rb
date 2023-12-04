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
    # TODO: Needs more logic to test whether the logic paths for update_waiting_list (status are same, not change in waiting list position, etc)
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
      it 'gets moved to the correct position' do
        FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 1)
        FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 2)
        FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 3)
        registration_4 = FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 4)
        FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 5)

        registration_4.update_competing_lane!({ waiting_list_position: 2 })
        registration_4.reload

        expect(registration_4.competing_waiting_list_position).to eq(2)
      end

      it 'when moved forward on the list, everything between its new and old position gets moved back' do
        FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 1)
        registration_2 = FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 2)
        registration_3 = FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 3)
        registration_4 = FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 4)
        FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 5)

        registration_4.update_competing_lane!({ waiting_list_position: 2 })
        registration_4.reload

        registration_2.reload
        registration_3.reload

        expect(registration_2.competing_waiting_list_position).to eq(3)
        expect(registration_3.competing_waiting_list_position).to eq(4)
      end

      it 'when moved forward, nothing outside the affected range changes' do
        registration_1 = FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 1)
        FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 2)
        FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 3)
        registration_4 = FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 4)
        registration_5 = FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 5)

        registration_4.update_competing_lane!({ waiting_list_position: 2 })
        registration_4.reload

        registration_1.reload
        registration_5.reload

        expect(registration_1.competing_waiting_list_position).to eq(1)
        expect(registration_5.competing_waiting_list_position).to eq(5)
      end

      it 'if moved backward, everything, everything between new and old position gets moved forward' do
        FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 1)
        registration_2 = FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 2)
        FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 3)
        FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 4)
        FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 5)

        registration_2.update_competing_lane!({ waiting_list_position: 4 })
        registration_2.reload

        expect(registration_2.competing_waiting_list_position).to eq(4)
      end

      it 'if moved backward, everything in front of its old position doesnt change' do
        FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 1)
        registration_2 = FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 2)
        registration_3 = FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 3)
        registration_4 = FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 4)
        FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 5)

        registration_2.update_competing_lane!({ waiting_list_position: 4 })
        registration_2.reload

        registration_3.reload
        registration_4.reload

        expect(registration_3.competing_waiting_list_position).to eq(2)
        expect(registration_4.competing_waiting_list_position).to eq(3)
      end
    end

    describe '#waiting_list.accept_from_waiting_list' do
      it 'when accepted, waiting_list_position gets set to nil' do
        registration = FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 1)
        registration.update_competing_lane!({ status: 'accepted' })
        expect(registration.competing_waiting_list_position).to eq(nil)
      end

      it 'if waiting list is empty, new min/max should be nil' do
        registration = FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 1)
        registration.update_competing_lane!({ status: 'accepted' })
        waiting_list_boundaries = registration.competing_lane.get_waiting_list_boundaries(registration.competition_id)
        expect(waiting_list_boundaries['waiting_list_position_min']).to eq(nil)
        expect(waiting_list_boundaries['waiting_list_position_max']).to eq(nil)
      end

      it 'if waiting list isnt empty, new min should be one greater than the accepted registrations old waiting list position' do
        registration = FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 1)
        FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 2)
        registration.update_competing_lane!({ status: 'accepted' })
        waiting_list_boundaries = registration.competing_lane.get_waiting_list_boundaries(registration.competition_id)
        expect(waiting_list_boundaries['waiting_list_position_min']).to eq(2)
        expect(waiting_list_boundaries['waiting_list_position_max']).to eq(2)
      end
    end

    describe '#waiting_list.remove_from_waiting_list' do
      it 'change from waiting_list to cancelled' do
        registration = FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 1)
        registration.update_competing_lane!({ status: 'cancelled' })
        expect(registration.competing_status).to eq('cancelled')
      end

      it 'change from waiting_list to pending' do
        registration = FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 1)
        registration.update_competing_lane!({ status: 'pending' })
        expect(registration.competing_status).to eq('pending')
      end

      it 'removing from waiting list changes waiting_list_position to nil' do
        registration = FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 1)
        registration.update_competing_lane!({ status: 'pending' })
        expect(registration.competing_waiting_list_position).to eq(nil)
      end

      it 'all registrations behind removed registration decrement their waiting_list_position' do
        registration = FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 1)
        registration_2 = FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 2)
        registration_3 = FactoryBot.create(:registration, registration_status: 'waiting_list', 'waiting_list_position' => 3)

        registration.update_competing_lane!({ status: 'pending' })

        registration_2.reload
        registration_3.reload

        expect(registration_2.competing_waiting_list_position).to eq(1)
        expect(registration_3.competing_waiting_list_position).to eq(2)
      end
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
