# frozen_string_literal: true

require 'csv'
require_relative '../csv_import'

namespace :import do
  include CsvImport
  desc 'Import registrations from CSV for specified competition_ids'
  task registrations: :environment do
    # SELECT c.id, e.event_ids FROM `Competitions` c JOIN ( SELECT `competition_id`, GROUP_CONCAT(DISTINCT `event_id` ORDER BY `event_id`) AS event_ids FROM `competition_events` GROUP BY `competition_id` ) e ON c.id = e.competition_id WHERE c.registration_close > "2024-07-01" 
    competitions_with_events_path = './lib/tasks/competitions_and_events.csv' # Use query above to generate this, changing the target date as appropriate
    registrations_csv_path = './lib/tasks/registrations_import.csv'

    # Step 1: Generate a list of competitions and their event_ids
    competitions_with_events = get_competitions_with_events(competitions_with_events_path)
    puts competitions_with_events

    # Step 2: Import records for each competition_id
    competitions_with_events.each do |competition_id, events|
      registrations = build_import_hash(registrations_csv_path, competition_id, events)
      # puts "***REGISTRATIONS TO CREATE:\n\n #{registrations}"

      registrations.each do |reg|
        puts reg
        Registration.create(reg)

        initial_history = History.new(
          { 'changed_attributes' => {
            event_ids: reg['competing.event_ids'],
            comment: reg['competing.comment'],
            guests: reg['guests'],
            status: reg['competing.registration_status']
          },
          'actor_type' => 'user',
          'actor_id' => reg[:user_id],
          'action' => 'Worker processed',
          'timestamp' => reg['competing.registered_on'] 
          }
        )
        RegistrationHistory.create(attendee_id: "#{competition_id}-#{reg[:user_id]}", entries: [initial_history])

      end
    end
  end

  def get_competitions_with_events(path)
    return_hash = {}

    CSV.foreach(path) do |row|
      return_hash[row[0]] = row[1].gsub(',', ';')
    end

    return_hash
  end

  def build_import_hash(csv_file_path, competition_id, event_ids)
    CSV.parse(File.read(csv_file_path), headers: true).map do |row|
      registration_data = row.to_h
      registration_data['competing.event_ids'] = event_ids

      registration = CsvImport.parse_row_to_registration(registration_data, competition_id)
      puts "\nBuild registration import hash: #{registration}"
      registration
    end
  end
end
