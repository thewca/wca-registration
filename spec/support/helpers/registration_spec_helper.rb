# frozen_string_literal: true

module Helpers
  module Registration
    RSpec.shared_context 'Registrations' do
      before do
        basic_registration = get_registration('CubingZANationalChampionship2023-158816')
        required_fields_only = get_registration('CubingZANationalChampionship2023-158817')
        missing_reg_fields = get_registration('')
        no_attendee_id = get_registration('CubingZANationalChampionship2023-158818')
      end
    end

    RSpec.shared_context '500 response from competition service' do
      before do
        error_json = { error:
          'Internal Server Error for url: /api/v0/competitions/CubingZANationalChampionship2023' }.to_json

        stub_request(:get, "https://www.worldcubeassociation.org/api/v0/competitions/#{competition_id}")
          .to_return(status: 500, body: error_json)
      end
    end

    RSpec.shared_context '502 response from competition service' do
      before do
        error_json =  { error: 'Internal Server Error for url: /api/v0/competitions/CubingZANationalChampionship2023' }.to_json

        stub_request(:get, "https://www.worldcubeassociation.org/api/v0/competitions/#{competition_id}")
          .to_return(status: 502, body: error_json)
      end
    end

    # Retrieves the saved JSON response of /api/v0/competitions for the given competition ID
    def get_competition_details(competition_id)
      File.open("#{Rails.root}/spec/fixtures/competition_details.json", 'r') do |f|
        competition_details = JSON.parse(f.read)

        # Retrieve the competition details when competition_id matches
        competition_details['competitions'].each do |competition|
          competition if competition['id'] == competition_id
        end
      end
    end

    def get_registration(attendee_id)
      File.open("#{Rails.root}/spec/fixtures/registrations.json", 'r') do |f|
        registrations = JSON.parse(f.read)

        # Retrieve the competition details when competition_id matches
        registrations.each do |registration|
          registration if registration['attendee_id'] == attendee_id
        end
      end
    end
  end
end
