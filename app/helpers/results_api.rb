# frozen_string_literal: true

require_relative 'error_codes'
require_relative 'wca_api'

class ResultsApi < WcaApi
  def self.get_psych_sheet(competition_id, event_id, sort_by: nil)
    response = HTTParty.post(psych_sheet_path(competition_id, event_id, sort_by: sort_by),
                             headers: { WCA_API_HEADER => self.get_wca_token })
    unless response.ok?
      raise 'Error from the results service'
    end
    response.body
  end

  class << self
    def psych_sheet_path(competition_id, event_id, sort_by: nil)
      base_route = "https://#{EnvConfig.WCA_HOST}/api/v0/competitions/#{competition_id}/psych-sheet/#{event_id}"

      if sort_by.present?
        return "#{base_route}?sort_by=#{sort_by}"
      end

      base_route
    end
  end
end
