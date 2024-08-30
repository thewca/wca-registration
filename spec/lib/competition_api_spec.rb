# frozen_string_literal: true

require 'rails_helper'

describe CompetitionApi, :tag do
  it 'raises RegistrationError when 404 is returned' do
    stub_request(:get, CompetitionApi.url('test')).to_return(status: 404)

    expect {
      CompetitionApi.find('test')
    }.to raise_error(RegistrationError) do |error|
      expect(error.http_status).to eq(404)
      expect(error.error).to eq(ErrorCodes::COMPETITION_NOT_FOUND)
    end
  end

  it 'raises RegistrationError when 404 is returned' do
    stub_request(:get, CompetitionApi.url('test')).to_return(status: 500)

    expect {
      CompetitionApi.find('test')
    }.to raise_error(RegistrationError) do |error|
      expect(error.http_status).to eq(500)
      expect(error.error).to eq(ErrorCodes::MONOLITH_API_ERROR)
    end
  end
end
