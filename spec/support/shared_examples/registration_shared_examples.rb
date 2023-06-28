RSpec.shared_examples 'optional field tests' do |payload|
  let!(:registration) { payload }

  run_test!
end

RSpec.shared_examples 'payload error tests' do |payload|
  let!(:registration) { payload }

  run_test!
end

RSpec.shared_examples 'cancel registration successfully' do |payload, competition_id, user_id|
  let!(:update) { payload }
  cancelled = "cancelled"

  run_test! do |response|
    registration = Registrations.find('CubingZANationalChampionship2023-158823')

    # Validate that registration is cancelled
    expect(registration[:lane_states][:competing]).to eq(cancelled)

    # Validate that lanes are cancelled
    lanes = registration[:lanes]
    lanes.each do |lane|
      expect(lane.lane_state).to eq(cancelled)

      # This will break if we add a non-competitor route in the test data
      events = lane.lane_details["event_details"]
      events.each do |event|
        expect(event["event_registration_state"]).to eq(cancelled)
      end
    end
  end
end
