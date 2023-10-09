# frozen_string_literal: true

require 'rails_helper'

describe CompetitionInfo do
  describe "competition_open?" do
    it "returns true if the competition is open" do
      # Create a sample competition JSON (adjust as needed)
      competition_json = { "registration_opened?" => true }

      # Instantiate a CompetitionInfo object with the sample data
      competition_info = CompetitionInfo.new(competition_json)

      # Call the method being tested
      result = competition_info.competition_open?

      # Expect the result to be true
      expect(result).to be true
    end
  end
end
