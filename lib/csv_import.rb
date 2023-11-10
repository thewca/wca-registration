# frozen_string_literal: true

module CsvImport
  HEADERS = %w[user_id guests competing.event_ids competing.registration_status competing.registered_on competing.comment competing.admin_comment].freeze
  def self.valid?(csv)
    data = CSV.parse(csv)
    headers = data.first
    headers.present? && headers.all? { |h| h.in?(HEADERS) }
  end

  def self.parse_row_to_registration(csv_hash, competition_id)
    {
      attendee_id: "#{competition_id}-#{csv_hash["user_id"]}",
      user_id: csv_hash['user_id'],
      competition_id: competition_id,
      lanes: [LaneFactory.competing_lane(event_ids: csv_hash['competing.event_ids'].split(';'), comment: csv_hash['competing.comment'], admin_comment: csv_hash['competing.admin_comment'],
                                         registration_status: csv_hash['competing.registration_status'])],
      isCompeting: csv_hash['competing.registration_status'] == 'accepted',
      guests: csv_hash['guests'],
    }
  end
end
