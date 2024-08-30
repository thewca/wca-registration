resource "aws_dynamodb_table" "registrations" {
  name           = "registrations-staging"
  billing_mode   = "PAY_PER_REQUEST"
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
    type = "N"
  }
  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }
  global_secondary_index {
    hash_key        = "competition_id"
    name            = "registrations-staging_index_competition_id"
    projection_type = "ALL"
  }

  global_secondary_index {
    hash_key        = "user_id"
    name            = "registrations-staging_index_user_id"
    projection_type = "ALL"
  }

  lifecycle {
    ignore_changes = [ttl]
  }
  tags = {
    Env = "staging"
  }
}

resource "aws_dynamodb_table" "registration_history" {
  name           = "registrations_history-staging"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key = "attendee_id"

  attribute {
    name = "attendee_id"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }

  lifecycle {
    ignore_changes = [ttl]
  }
  tags = {
    Env = "staging"
  }
}
