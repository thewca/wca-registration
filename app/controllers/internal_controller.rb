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
    registrations = Registration.where(user_id: user_id).to_a
    render json: registrations
  end

  def show_registration
    attendee_id = params.require(:attendee_id)
    registration = Registration.find(attendee_id)
    render json: registration
  end

  def import_registrations
    competition_id = params.require(:competition_id)
    to_create = params[:create] || []
    to_update = params[:update] || []
    to_delete = params[:delete] || []
    if to_create.any?
      puts(to_create.map { |r| { attendee_id: r["attendee_id"], entries: [{ 'changed_attributes' =>
                                                                { event_ids: r["event_ids"], status: r["competing_status"] },
                                                              'actor_type' => r["actor_type"],
                                                              'actor_id' => r["actor_id"],
                                                              'action' => 'Import',
                                                              'timestamp' => Time.now }] } }.inspect)
      RegistrationHistory.import(to_create.map do |r|
        {
          attendee_id: r["attendee_id"],
          entries: [History.new({
                      'changed_attributes' => {
                        event_ids: r["event_ids"],
                        status: r["competing_status"]
                      },
                      'actor_type' => r["actor_type"],
                      'actor_id' => r["actor_id"],
                      'action' => 'Import',
                      'timestamp' => Time.now
                    })]
        }
      end)
      Registration.import(to_create.map do |r|
        {
          attendee_id: r["attendee_id"],
          competition_id: competition_id,
          user_id: r["user_id"],
          competing_status: r["competing_status"],
          lanes: [
            LaneFactory.competing_lane(
              event_ids: r["event_ids"],
              registration_status: r["competing_status"]
            )
          ]
        }
      end)
    end
    to_update.each do |r|
      registration = Registration.find(r["attendee_id"])
      registration.update(r["attendee_id"], competing_status: r["competing_status"], lanes: [LaneFactory.competing_lane(event_ids: r["event_ids"], registration_status: r["competing_status"])])
      registration.history.add_entry({ event_ids: r["event_ids"], status: r["competing_status"] }, r["actor_type"], r["actor_id"], "import")
    end
    to_delete.each do |r|
      Registration.update(r["attendee_id"], competing_status: "cancelled", lanes: [LaneFactory.competing_lane(event_ids: r["event_ids"], registration_status: "cancelled" )])
      registration.history.add_entry({ event_ids: r["event_ids"], status: "cancelled" }, r["actor_type"], r["actor_id"], "import")
    end
  render json: { errors: [] }
  rescue StandardError => e
    return render json: { errors: [e.to_s] }, status: :unprocessable_entity
  end
end
