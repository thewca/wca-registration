# frozen_string_literal: true

module CsvImport
  HEADERS = %w[user_id guests competing.event_ids competing.registration_status competing.registered_on competing.comment competing.admin_comment]
  def self.valid?(csv)
    data = CSV.parse(csv)
    headers = data.first
    headers.present? && headers.all? {|h| h.in?(HEADERS)}
  end
end