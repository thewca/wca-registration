# frozen_string_literal: true

# Failsafe so this is never run in production (the task doesn't have permissions to create tables anyway)
unless Rails.env.production?
  # Create the DynamoDB Tables
  table_name = EnvConfig.DYNAMO_REGISTRATIONS_TABLE
  key_schema = [
    { attribute_name: 'attendee_id', key_type: 'HASH' },
  ]
  attribute_definitions = [
    { attribute_name: 'attendee_id', attribute_type: 'S' },
    { attribute_name: 'user_id', attribute_type: 'S' },
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
    $dynamodb.create_table({
                             table_name: table_name,
                             key_schema: key_schema,
                             attribute_definitions: attribute_definitions,
                             provisioned_throughput: provisioned_throughput,
                             global_secondary_indexes: global_secondary_indexes,
                           })
    # Add some registrations for each comp for testing
    require_relative '../app/models/registration'
    comps = %w[KoelnerKubing2023 LowLimit2023 FMCFrance2023 RheinNeckarAutumn2023 HessenOpen2023 ManchesterSpring2024 SeriesComp1 SeriesComp2 PickeringFavouritesAutumn2023 EventRegLimit]
    comps.each_with_index do |id, i|
      competition = Mocks.mock_competition(id)
      (9001..9005).each do |user_id|
        Registration.create(attendee_id: "#{id}-#{user_id}", competition_id: id, user_id: user_id, guests: rand(1..10),
                            lanes: [LaneFactory.competing_lane(event_ids: competition['event_ids'].sample(rand(1..3)), comment: "Seed Registration #{user_id}")])
      end
    end
  rescue Aws::DynamoDB::Errors::ResourceInUseException
    puts 'Database Already exists'
  end

  # Create SQS Queue
  queue_name = 'registrations.fifo'
  $sqs.create_queue({
                      queue_name: queue_name,
                      attributes: {
                        FifoQueue: 'true',
                      },
                    })
end
