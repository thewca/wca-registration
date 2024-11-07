# frozen_string_literal: true

require 'time'

class InternalController < ApplicationController
  prepend_before_action :validate_wca_token unless Rails.env.local?
  skip_before_action :validate_jwt_token

  def validate_wca_token
    service_token = request.headers['X-WCA-Service-Token']
    if service_token.blank?
      return render json: { error: 'Missing Authentication' }, status: :forbidden
    end
    # The Vault CLI can't parse the response from identity/oidc/introspect so
    # we need to request it instead see https://github.com/hashicorp/vault/issues/9080

    vault_token_data = Vault.auth_token.lookup_self.data
    # Renew our token if it has expired or is close to expiring
    if vault_token_data[:ttl] < 300
      Vault.auth_token.renew_self
    end

    # Make the POST request to the introspect endpoint
    response = HTTParty.post("#{EnvConfig.VAULT_ADDR}/v1/identity/oidc/introspect",
                             body: { token: service_token }.to_json,
                             headers: { 'X-Vault-Token' => vault_token_data[:id],
                                        'Content-Type' => 'application/json' })
    if response.ok?
      unless response['active']
        render json: { error: 'Authentication Expired or Token Invalid' }, status: :forbidden
      end
    else
      raise "Introspection failed with the following error: #{response.status}, #{response.body}"
    end
  end

  def update_payment_status
    attendee_id = params.require(:attendee_id)
    payment_id = params.require(:payment_id)
    iso_amount = params.require(:iso_amount)
    currency_iso = params.require(:currency_iso)
    payment_status = params.require(:payment_status)
    acting_id = params.require(:acting_id)
    acting_type = params.require(:acting_type)
    registration = Registration.find(attendee_id)
    registration.update_payment_lane(payment_id, iso_amount, currency_iso, payment_status)
    if payment_status == 'refund'
      registration.history.add_entry({ payment_status: payment_status, iso_amount: iso_amount }, acting_type, acting_id, 'Payment Refund')
    else
      registration.history.add_entry({ payment_status: payment_status, iso_amount: iso_amount }, acting_type, acting_id, 'Payment')
    end
    render json: { status: 'ok' }
  end

  def list_registrations
    competition_id = params.require(:competition_id)

    status = params[:status]
    event_id = params[:event_id]

    registrations = if status.present?
                      Registration.where(competition_id: competition_id, competing_status: status).to_a
                    else
                      Registration.where(competition_id: competition_id).to_a
                    end

    if event_id.present?
      return render json: registrations.filter { |r| r.event_details.pluck('event_id').include?(event_id) }
    end

    render json: registrations
  end

  def registrations_for_user
    user_id = params.require(:user_id)
    registrations = Rails.cache.fetch("#{user_id}-registrations-by-user") do
      Registration.where(user_id: user_id).to_a
    end
    render json: registrations
  end

  def create
    user_id = params.require(:user_id)
    competition_id = params.require(:competition_id)
    event_ids = params.require(:event_ids)
    current_user = params.require(:current_user)
    status = params.require(:competing_status)
    comment = params[:comment] || ''

    begin
      Registration.find("#{competition_id}-#{user_id}")
      render_error(400, ErrorCodes::COMPETITOR_ALREADY_REGISTERED)
    rescue Dynamoid::Errors::RecordNotFound
      initial_history = History.new({ 'changed_attributes' =>
                                        { event_ids: event_ids, status: status, comment: comment },
                                      'actor_type' => 'user',
                                      'actor_id' => current_user,
                                      'action' => 'Organizer added',
                                      'timestamp' => Time.now.utc })
      RegistrationHistory.create(attendee_id: "#{competition_id}-#{user_id}", entries: [initial_history])
      Registration.create(attendee_id: "#{competition_id}-#{user_id}",
                          competition_id: competition_id,
                          user_id: user_id,
                          created_at: Time.now.utc,
                          lanes: [LaneFactory.competing_lane(event_ids: event_ids,
                                                             comment: comment,
                                                             registration_status: status)],
                          guests: 0)
      render json: { status: 'ok' }
    end
  end

  def show_registration
    attendee_id = params.require(:attendee_id)
    registration = Registration.find(attendee_id)
    render json: registration
  end

  def history
    attendee_id = params.require(:attendee_id)
    history = RegistrationHistory.find(attendee_id)
    render json: history
  end
end
