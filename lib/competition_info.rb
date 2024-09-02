# frozen_string_literal: true

class CompetitionInfo
  attr_accessor :competition_id, :waiting_list

  def initialize(competition_json)
    @competition_json = competition_json
    @competition_id = competition_json['id']
    @qualifications = fetch_qualifications
    @waiting_list = WaitingList.find_or_create!(@competition_id)
  end

  def start_date
    @competition_json['start_date']
  end

  def within_event_change_deadline?
    return true if @competition_json['event_change_deadline_date'].nil?
    Time.now.utc < @competition_json['event_change_deadline_date']
  end

  def competitor_limit
    @competition_json['competitor_limit']
  end

  def guest_limit_exceeded?(guest_count)
    return false if @competition_json['guests_per_registration_limit'].blank?
    @competition_json['guest_entry_status'] == 'restricted' && @competition_json['guests_per_registration_limit'] < guest_count
  end

  def event_limit
    if @competition_json['events_per_registration_limit'].is_a? Integer
      @competition_json['events_per_registration_limit']
    else
      nil
    end
  end

  def guest_limit
    @competition_json['guests_per_registration_limit']
  end

  def registration_open?
    @competition_json['registration_currently_open?']
  end

  def using_wca_payment?
    @competition_json['using_payment_integrations?']
  end

  def force_comment?
    @competition_json['force_comment_in_registration']
  end

  def events_held?(event_ids)
    event_ids != [] && @competition_json['event_ids'].to_set.superset?(event_ids.to_set)
  end

  def payment_info
    [@competition_json['base_entry_fee_lowest_denomination'], @competition_json['currency_code']]
  end

  def is_organizer_or_delegate?(user_id)
    (@competition_json['delegates'] + @competition_json['organizers']).any? { |p| p['id'] == user_id }
  end

  def name
    @competition_json['name']
  end

  def id
    @competition_json['id']
  end

  def registration_edits_allowed?
    @competition_json['allow_registration_edits'] && within_event_change_deadline?
  end

  def user_can_cancel?
    @competition_json['allow_registration_self_delete_after_acceptance']
  end

  def other_series_ids
    @competition_json['competition_series_ids']&.reject { |id| id == competition_id }
  end

  private def fetch_qualifications
    return nil unless enforces_qualifications?
    @qualifications = CompetitionApi.fetch_qualifications(@competition_id)
  end

  def enforces_qualifications?
    @competition_json['qualification_results'] && !@competition_json['allow_registration_without_qualification']
  end

  def get_qualification_for(event)
    @qualifications[event]
  end
end
