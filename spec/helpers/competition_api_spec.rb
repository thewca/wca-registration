# frozen_string_literal: true

require 'rails_helper'
require_relative '../../app/helpers/competition_api'

describe CompetitionInfo do
  context 'competition object' do
    # TODO: Refactor tests to use a factory, not explicitly defined JSON
    describe "#competition_open?" do
      it "true when open" do
        # Create a sample competition JSON (adjust as needed)
        competition_json = { "registration_opened?" => true }

        # Instantiate a CompetitionInfo object with the sample data
        competition_info = CompetitionInfo.new(competition_json)

        # Call the method being tested
        result = competition_info.competition_open?

        # Expect the result to be true
        expect(result).to be true
      end

      it "false when closed" do
        # Create a sample competition JSON (adjust as needed)
        competition_json = { "registration_opened?" => false }

        # Instantiate a CompetitionInfo object with the sample data
        competition_info = CompetitionInfo.new(competition_json)

        # Call the method being tested
        result = competition_info.competition_open?

        # Expect the result to be true
        expect(result).to be false
      end
    end

    describe "#using_wca_payment?" do
      it "PASSING true if the competition uses WCA paymet" do
        # Create a sample competition JSON (adjust as needed)
        competition_json = { "using_stripe_payments?" => true }

        # Instantiate a CompetitionInfo object with the sample data
        competition_info = CompetitionInfo.new(competition_json)

        # Call the method being tested
        result = competition_info.using_wca_payment?

        # Expect the result to be true
        expect(result).to be true
      end

      it "PASSING false if the competition doesn't use WCA paymet" do
        # Create a sample competition JSON (adjust as needed)
        competition_json = { "using_stripe_payments?" => false }

        # Instantiate a CompetitionInfo object with the sample data
        competition_info = CompetitionInfo.new(competition_json)

        # Call the method being tested
        result = competition_info.using_wca_payment?

        # Expect the result to be true
        expect(result).to be false
      end
    end

    describe "#events_held?" do
      it 'PASSING true if competition is hosting given events' do
        # Create a sample competition JSON (adjust as needed)
        competition_json = { "event_ids" => ["333", "444", "555"] }

        # Instantiate a CompetitionInfo object with the sample data
        competition_info = CompetitionInfo.new(competition_json)

        # Call the method being tested
        result = competition_info.events_held?(["333", "444"])

        # Expect the outcome
        expect(result).to be true
      end

      it 'PASSING true if events list is empty' do
        # Create a sample competition JSON (adjust as needed)
        competition_json = { "event_ids" => ["333", "444", "555"] }

        # Instantiate a CompetitionInfo object with the sample data
        competition_info = CompetitionInfo.new(competition_json)

        # Call the method being tested
        result = competition_info.events_held?([])

        # Expect the outcome
        expect(result).to be true
      end

      it 'PASSING false if one of the events is not being hosted' do
        # Create a sample competition JSON (adjust as needed)
        competition_json = { "event_ids" => ["333", "444", "555"] }

        # Instantiate a CompetitionInfo object with the sample data
        competition_info = CompetitionInfo.new(competition_json)

        # Call the method being tested
        result = competition_info.events_held?(["666"])

        # Expect the outcome
        expect(result).to be false
      end

      it 'PASSING returns competition payment info' do
        # Create a sample competition JSON (adjust as needed)
        competition_json = {
          "base_entry_fee_lowest_denomination" => 1500,
          "currency_code" => "EUR",
        }

        # Instantiate a CompetitionInfo object with the sample data
        competition_info = CompetitionInfo.new(competition_json)

        # Call the method being tested
        result = competition_info.payment_info

        # Expect the outcome
        expect(result).to eq [1500, "EUR"]
      end
    end
  end
end
