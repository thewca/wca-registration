# frozen_string_literal: true

class PsychSheetController < ApplicationController
  skip_before_action :validate_token, only: [:fetch]

  def fetch
    competition_id = list_params
    registrations = get_attending_registrations(competition_id)

    user_ids = registrations.map { |reg| reg[:user_id] }
    pseudo_rankings = user_ids.map { |uid|
      {
        user_id: uid.to_i,
        single_rank: uid.to_i * 3,
        single_best: '12.34',
        average_rank: uid.to_i ** 2,
        average_best: '59.99',
      }
    }

    render json: {
      sort_by: 'single',
      sort_by_secondary: 'average',
      sorted_rankings: pseudo_rankings,
    }
  end

  def list_params
    params.require(:competition_id)
  end

  def get_attending_registrations(competition_id)
    Registration.where(competition_id: competition_id, competing_status: 'accepted').all.map do |x|
      { user_id: x['user_id'],
        competing: {
          event_ids: x.event_ids,
        } }
    end
  end
end
