resource "aws_dynamodb_table" "registrations" {
  name           = "registrations"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key = "attendee_id"

  attribute {
    name = "attendee_id"
    type = "S"
  }

  attribute {
    name = "competition_id"
    type = "S"
  }

  attribute {
    name = "user_id"
    type = "S"
  }
  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }
  global_secondary_index {
    hash_key        = "competition_id"
    name            = "registrations_index_competition_id"
    projection_type = "ALL"
    write_capacity = 5
    read_capacity = 5
  }

  global_secondary_index {
    hash_key        = "user_id"
    name            = "registrations_index_user_id"
    projection_type = "ALL"
    write_capacity = 5
    read_capacity = 5
  }

  lifecycle {
    ignore_changes = [ttl]
  }
}

output "dynamo_registration_table" {
  value = aws_dynamodb_table.registrations
}

# Add autoscaling
module "table_autoscaling" {
  source  = "snowplow-devops/dynamodb-autoscaling/aws"
  version = "0.2.1"
  table_name = aws_dynamodb_table.registrations.id
  read_max_capacity = 100
  read_min_capacity = 5
  read_scale_in_cooldown = 30
  read_scale_out_cooldown = 30
  read_target_value = 75
  write_max_capacity = 100
  write_min_capacity = 5
  write_scale_in_cooldown = 30
  write_scale_out_cooldown = 30
  write_target_value = 85
}
