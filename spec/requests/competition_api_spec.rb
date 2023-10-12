# frozen_string_literal: true

require 'rails_helper'
require_relative '../../app/helpers/competition_api'

describe CompetitionInfo do
  describe "Initializing object" do
    it "PASSING Initializes successfully with a valid competition_id" do
      competition = FactoryBot.build(:competition_details)
      stub_request(:get, "#{BASE_COMP_URL}CubingZANationalChampionship2023").to_return(status: 200, body: competition.to_json)

      competition_info = CompetitionApi.new('CubingZANationalChampionship2023').competition_info

      expect(competition_info.class).to eq(CompetitionInfo)
    end

    it 'PASSING errors when competition_id doesnt exist' do
      wca_error_json = { error: 'Competition with id InvalidCompId not found' }.to_json
      stub_request(:get, "#{BASE_COMP_URL}InvalidCompId").to_return(status: 404, body: wca_error_json)

      competition_response = CompetitionApi.new('InvalidCompId')

      expect(competition_response.competition_exists?).to eq(false)
      expect(competition_response.error).to eq(ErrorCodes::COMPETITION_NOT_FOUND)
      expect(competition_response.status).to eq(404)
    end

    it 'PASSING errors when comp api unavailable' do
      error_json = { error: "Internal Server Error for url: /api/v0/competitions/UnavailableComp" }.to_json
      stub_request(:get, "#{BASE_COMP_URL}UnavailableComp").to_return(status: 500, body: error_json)

      competition_info = CompetitionApi.new('UnavailableComp')

      expect(competition_info.competition_exists?).to eq(false)
      expect(competition_info.error).to eq(ErrorCodes::COMPETITION_API_5XX)
      expect(competition_info.status).to eq(500)
    end
  end
end
