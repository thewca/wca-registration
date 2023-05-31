module Helpers
  module Registration
    def get_competition_details competition_id
      # Open the json file called 'competition_details.json'
      File.open("#{Rails.root}/spec/fixtures/competition_details.json", 'r') do |f|
        competition_details = JSON.parse(f.read)

        # Retrieve the competition details
        competition_details['competitions'].each do |competition|
          puts competition if competition['id'] == competition_id
        end
      end
    end
  end
end
