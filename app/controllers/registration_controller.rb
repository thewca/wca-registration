require 'securerandom'
class RegistrationController < ApplicationController
  def create
    competitor_id = params[:competitor_id]
    competition_id = params[:competition_id]
    event_ids = params[:event_ids]

    unless user_can_register(competitor_id, competition_id)
      return render json: { status: 'User cannot register, wrong format' }, status: :forbidden
    end

    registration = {
      id: SecureRandom.uuid,
      competitor_id: competitor_id,
      competition_id: competition_id,
      registration_data: {
        event_ids: event_ids
      }
    }

    $dynamodb.put_item({
       table_name: 'Registrations',
       item: registration
    })

    render json: { status: 'ok' }
  end

  def list
    competition_id = params[:competition_id]
    registrations = get_registrations(competition_id)

    render json: registrations
  end

  private

  def user_can_register(competitor_id, competition_id)
    # check that competitor ID is in the correct format
    if competitor_id =~ /^\d{4}[a-zA-Z]{4}\d{2}$/
      # check that competition ID is in the correct format
      if competition_id =~ /^[a-zA-Z]+\d{4}$/
        return true
      end
    end
    false
  end



  def get_registrations(competition_id)
    # Query DynamoDB for registrations with the given competition_id
    resp = $dynamodb.query({
      table_name: 'Registrations',
      key_condition_expression: '#ci = :cid',
      expression_attribute_names: { '#ci' => 'competition_id' },
      expression_attribute_values: { ':cid' => competition_id }
    })

    # Return the items from the response
    resp.items
  end
end
