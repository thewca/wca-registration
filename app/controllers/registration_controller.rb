require 'securerandom'
class RegistrationController < ApplicationController
  def create
    competitor_id = params[:competitor_id]
    competition_id = params[:competition_id]
    event_ids = params[:event_ids]

    unless validate_request(competitor_id, competition_id)
      return render json: { status: 'User cannot register, wrong format' }, status: :forbidden
    end

    id = SecureRandom.uuid

    step_data = {
      competitor_id: competitor_id,
      competition_id: competition_id,
      event_ids: event_ids,
      registration_status: "waiting",
      step: "Event Registration"
    }
    $queue = Aws::SQS::Queue.new($sqs.get_queue_url(queue_name: "registrations.fifo").queue_url)

    $queue.send_message({
     queue_url: $queue,
     message_body: step_data.to_json,
     message_group_id: id,
     message_deduplication_id: id
     })

    render json: { status: 'ok', message: "Started Registration Process" }
  end

  def update
    competitor_id = params[:competitor_id]
    competition_id = params[:competition_id]
    status = params[:status]

    unless validate_request(competitor_id, competition_id, status)
      return render json: { status: 'User cannot register, wrong format' }, status: :forbidden
    end

    # Specify the key attributes for the item to be updated
    key = {
      'competitor_id' => competitor_id,
      'competition_id' => competition_id
    }

    # Set the expression for the update operation
    update_expression = 'set registration_status = :s'
    expression_attribute_values = {
      ':s' => status
    }

    begin
      # Update the item in the table
      $dynamodb.update_item({
         table_name: "Registrations",
         key: key,
         update_expression: update_expression,
         expression_attribute_values: expression_attribute_values
       })
      return render json: { status: 'ok' }
    rescue Aws::DynamoDB::Errors::ServiceError => e
      return render json: { status: 'Failed to update registration data' }, status: :internal_server_error
    end
  end

  def delete
    competitor_id = params[:competitor_id]
    competition_id = params[:competition_id]

    unless validate_request(competitor_id, competition_id)
      return render json: { status: 'User cannot register, wrong format' }, status: :forbidden
    end

    # Define the key of the item to delete
    key = {
      "competition_id" => competition_id,
      "competitor_id" => competitor_id
    }

    begin
      # Call the delete_item method to delete the item from the table
      $dynamodb.delete_item(
        table_name: "Registrations",
        key: key
      )

      # Render a success response
      return render json: { status: 'ok' }

    rescue Aws::DynamoDB::Errors::ServiceError => error
      # Render an error response
      return render json: { status: "Error deleting item from DynamoDB: #{error.message}" }, status: :internal_server_error
    end
  end
  def list
    competition_id = params[:competition_id]
    registrations = get_registrations(competition_id)

    render json: registrations
  end

  private

  REGISTRATION_STATUS = %w[waiting accepted]

  def validate_request(competitor_id, competition_id, status="waiting")
    # check that competitor ID is in the correct format
    if competitor_id =~ /^\d{4}[a-zA-Z]{4}\d{2}$/
      # check that competition ID is in the correct format
      if competition_id =~ /^[a-zA-Z]+\d{4}$/ and REGISTRATION_STATUS.include? status
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
