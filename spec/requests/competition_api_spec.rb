# frozen_string_literal: true

require 'rails_helper'
require_relative '../../app/helpers/competition_api'

describe CompetitionInfo do
  describe 'Initializing object' do
    it 'PASSING Initializes successfully with a valid competition_id' do
      competition = FactoryBot.build(:competition)
      stub_request(:get, comp_api_url(competition[:competition_id])).to_return(status: 200, body: competition.to_json)

      competition_info = CompetitionApi.find!(competition[:competition_id])

      expect(competition_info.class).to eq(CompetitionInfo)
    end

    it 'PASSING errors when competition_id doesnt exist' do
      wca_error_json = { error: 'Competition with id InvalidCompId not found' }.to_json
      stub_request(:get, comp_api_url('InvalidCompId')).to_return(status: 404, body: wca_error_json)

      expect {
        CompetitionApi.find!('InvalidCompId')
      }.to raise_error(RegistrationError) { |error|
        expect(error.error).to eq(ErrorCodes::COMPETITION_NOT_FOUND)
        expect(error.http_status).to eq(404)
      }
    end

    it 'PASSING errors when comp api unavailable' do
      error_json = { error: 'Internal Server Error for url: /api/v0/competitions/UnavailableComp' }.to_json
      stub_request(:get, comp_api_url('UnavailableComp')).to_return(status: 500, body: error_json)

      expect {
        CompetitionApi.find!('UnavailableComp')
      }.to raise_error(RegistrationError) { |error|
        expect(error.error).to eq(ErrorCodes::COMPETITION_API_5XX)
        expect(error.http_status).to eq(500)
      }
    end
  end
end
