require 'aws-sdk-dynamodb'

class RegistrationProcessor
  def self.process_message(message)
    if ENV['LOCALSTACK_ENDPOINT']
      @dynamodb ||= Aws::DynamoDB::Client.new(endpoint: ENV['LOCALSTACK_ENDPOINT'])
    else
      @dynamodb ||= Aws::DynamoDB::Client.new
    end
    # implement your message processing logic here
    puts "Working on Message: #{message}"
    if message['step'] == "Event Registration"
      registration = {
        competitor_id: message['competitor_id'],
        competition_id: message['competition_id'],
        event_ids: message['event_ids'],
        registration_status: "waiting",
      }
      save_registration(registration)
    end
  end

  private

  def self.save_registration(registration)
    @dynamodb.put_item({
       table_name: 'Registrations',
       item: registration
     })
  end
end
