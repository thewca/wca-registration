# Create the DynamoDB Tables
table_name = 'Registrations'
key_schema = [
  { attribute_name: 'competition_id', key_type: 'HASH' },
  { attribute_name: 'competitor_id', key_type: 'RANGE' }
]
attribute_definitions = [
  { attribute_name: 'competition_id', attribute_type: 'S' },
  { attribute_name: 'competitor_id', attribute_type: 'S' }
]
provisioned_throughput = {
  read_capacity_units: 5,
  write_capacity_units: 5
}
$dynamodb.create_table({
 table_name: table_name,
 key_schema: key_schema,
 attribute_definitions: attribute_definitions,
 provisioned_throughput: provisioned_throughput
})

# Create SQS Queue
queue_name = 'registrations.fifo'
$sqs.create_queue({
                    queue_name: queue_name,
                    attributes: {
                      "FifoQueue": "true"
                    }
                  })
