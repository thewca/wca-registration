# frozen_string_literal: true

class PsychSheetController < ApplicationController
  skip_before_action :validate_token, only: [:fetch]

  def fetch
    competition_id = params.require(:competition_id)
    event_id = params.require(:event_id)

    sort_by = params[:sort_by]

    render json: ResultsApi.get_psych_sheet(competition_id, event_id, sort_by: sort_by)
  end
end
