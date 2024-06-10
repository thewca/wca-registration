# frozen_string_literal: true

# Failsafe so this is never run in production (the task doesn't have permissions to create tables anyway)
unless Rails.env.production?
  dynamodb = Aws::DynamoDB::Client.new(endpoint: EnvConfig.LOCALSTACK_ENDPOINT)
  sqs = Aws::SQS::Client.new(endpoint: EnvConfig.LOCALSTACK_ENDPOINT)
  # Create the DynamoDB Tables
  table_name = EnvConfig.DYNAMO_REGISTRATIONS_TABLE
  key_schema = [
    { attribute_name: 'attendee_id', key_type: 'HASH' },
  ]
  attribute_definitions = [
    { attribute_name: 'attendee_id', attribute_type: 'S' },
    { attribute_name: 'user_id', attribute_type: 'N' },
    { attribute_name: 'competition_id', attribute_type: 'S' },
  ]
  provisioned_throughput = {
    read_capacity_units: 5,
    write_capacity_units: 5,
  }
  global_secondary_indexes = [
    {
      index_name: "#{table_name}_index_competition_id",
      key_schema: [
        { attribute_name: 'competition_id', key_type: 'HASH' },
      ],
      projection: {
        projection_type: 'ALL',
      },
      provisioned_throughput: {
        read_capacity_units: 5,
        write_capacity_units: 5,
      },
    },
    {
      index_name: "#{table_name}_index_user_id",
      key_schema: [
        { attribute_name: 'user_id', key_type: 'HASH' },
      ],
      projection: {
        projection_type: 'ALL',
      },
      provisioned_throughput: {
        read_capacity_units: 5,
        write_capacity_units: 5,
      },
    },
  ]
  begin
    dynamodb.create_table({
                             table_name: table_name,
                             key_schema: key_schema,
                             attribute_definitions: attribute_definitions,
                             provisioned_throughput: provisioned_throughput,
                             global_secondary_indexes: global_secondary_indexes,
                           })
  rescue Aws::DynamoDB::Errors::ResourceInUseException
    Rails.logger.debug 'Database Already exists'
  end

  # Create SQS Queue
  queue_name = 'registrations.fifo'
  sqs.create_queue({
                      queue_name: queue_name,
                      attributes: {
                        FifoQueue: 'true',
                      },
                    })
end
