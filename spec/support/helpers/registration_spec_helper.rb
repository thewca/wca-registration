# frozen_string_literal: true

module Helpers
  module Registration
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
