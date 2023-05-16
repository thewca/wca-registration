resource "aws_dynamodb_table" "registrations" {
  name           = "Registrations"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key = "competition_id"
  range_key = "competitor_id"

  attribute {
    name = "competition_id"
    type = "S"
  }

  attribute {
    name = "competitor_id"
    type = "S"
  }
  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }

  lifecycle {
    ignore_changes = [ttl]
  }
}

output "dynamo_registration_table" {
  value = aws_dynamodb_table.registrations.arn
}
