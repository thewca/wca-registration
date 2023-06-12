resource "aws_dynamodb_table" "registrations" {
  name           = "registrations-staging"
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
    name            = "competition_id"
    projection_type = "ALL"
  }

  global_secondary_index {
    hash_key        = "user_id"
    name            = "user_id"
    projection_type = "ALL"
  }

  lifecycle {
    ignore_changes = [ttl]
  }
  tags = {
    Env = "staging"
  }
}
