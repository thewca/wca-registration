require 'json'
require 'dynamoid'
require 'aws-sdk-dynamodb'
require 'aws-sdk-sqs'

Dynamoid.configure do |config|
  config.region = ENV.fetch("AWS_REGION", 'us-west-2')
  config.namespace = nil
end
# We have to require the model after we initialized dynamoid
# This is copied over when bundling the lambda
require_relative './registration'

def lambda_handler(event:, context:)
  # Parse the input event
  query = event['queryStringParameters']
  if query.nil? || query["attendee_id"].nil?
    response = {
      statusCode: 400,
      body: JSON.generate({ status: 'Missing fields in request' })
    }
  else
    queue_url = ENV.fetch("QUEUE_URL", nil)
    sqs_client = Aws::SQS::Client.new(region: ENV.fetch("AWS_REGION", 'us-west-2'))

    queue_attributes = sqs_client.get_queue_attributes({
                                                         queue_url: queue_url,
                                                         attribute_names: ["ApproximateNumberOfMessages"]
                                                       })
    message_count = queue_attributes.attributes["ApproximateNumberOfMessages"].to_i

    registration = Registration.find(query["attendee_id"])

    # If we are **really** busy, the lane_init function might not be run yet before we start polling
    # So while we return a 404 here, it doesn't necessarily mean the registration doesn't exist at all
    if registration.nil?
      response = {
        statusCode: 404,
        body: JSON.generate({ status: 'not found', queue_count: message_count  })
      }
    else
      competing_status = registration.competing_status

      response = {
        statusCode: 200,
        body: JSON.generate({ status: competing_status, queue_count: message_count })
      }
    end
  end

  # Return the response
  {
    statusCode: response[:statusCode],
    body: response[:body]
  }
rescue => e
  # Handle any errors
  {
    statusCode: 500,
    body: JSON.generate({ error: e.message })
  }
end
