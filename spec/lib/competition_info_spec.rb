# frozen_string_literal: true

require 'rails_helper'

describe CompetitionInfo do
  context 'competition object' do
    competition_json = FactoryBot.build(:competition)

    # TODO: Refactor tests to use a factory, not explicitly defined JSON
    describe '#registration_open?' do
      it 'true when open' do
        # Instantiate a CompetitionInfo object with the sample data
        competition_info = CompetitionInfo.new(competition_json)

        # Call the method being tested
        result = competition_info.registration_open?

        # Expect the result to be true
        expect(result).to be true
      end

      it 'false when closed' do
        # Instantiate a CompetitionInfo object with the sample data
        competition_json = FactoryBot.build(:competition, :closed)
        competition_info = CompetitionInfo.new(competition_json)

        # Call the method being tested
        result = competition_info.registration_open?

        # Expect the result to be true
        expect(result).to be false
      end
    end

    describe '#using_wca_payment?' do
      it 'PASSING true if the competition uses WCA payment' do
        # Instantiate a CompetitionInfo object with the sample data
        competition_info = CompetitionInfo.new(competition_json)

        # Call the method being tested
        result = competition_info.using_wca_payment?

        # Expect the result to be true
        expect(result).to be true
      end

      it "PASSING false if the competition doesn't use WCA payment" do
        # Instantiate a CompetitionInfo object with the sample data
        competition_info = CompetitionInfo.new(FactoryBot.build(:competition, using_payment_integrations?: false))

        # Call the method being tested
        result = competition_info.using_wca_payment?

        # Expect the result to be true
        expect(result).to be false
      end
    end

    describe '#events_held?' do
      it 'PASSING true if competition is hosting given events' do
        # Create a sample competition JSON (adjust as needed)
        competition_json = FactoryBot.build(:competition, event_ids: %w[333 444 555])

        # Instantiate a CompetitionInfo object with the sample data
        competition_info = CompetitionInfo.new(competition_json)

        # Call the method being tested
        result = competition_info.events_held?(['333', '444'])

        # Expect the outcome
        expect(result).to be true
      end

      it 'PASSING false if events list is empty' do
        # Create a sample competition JSON (adjust as needed)
        competition_json = FactoryBot.build(:competition, event_ids: %w[333 444 555])

        # Instantiate a CompetitionInfo object with the sample data
        competition_info = CompetitionInfo.new(competition_json)

        # Call the method being tested
        result = competition_info.events_held?([])

        # Expect the outcome
        expect(result).to be false
      end

      it 'PASSING false if one of the events is not being hosted' do
        # Create a sample competition JSON (adjust as needed)
        competition_json = FactoryBot.build(:competition, event_ids: %w[333 444 555])

        # Instantiate a CompetitionInfo object with the sample data
        competition_info = CompetitionInfo.new(competition_json)

        # Call the method being tested
        result = competition_info.events_held?(['666'])

        # Expect the outcome
        expect(result).to be false
      end

      it 'PASSING returns competition payment info' do
        # Instantiate a CompetitionInfo object with the sample data
        competition_info = CompetitionInfo.new(FactoryBot.build(:competition, base_entry_fee_lowest_denomination: 1500, currency_code: 'EUR'))

        # Call the method being tested
        result = competition_info.payment_info

        # Expect the outcome
        expect(result).to eq [1500, 'EUR']
      end
    end
  end
end
