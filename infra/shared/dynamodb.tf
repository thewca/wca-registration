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
    type = "N"
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

  point_in_time_recovery {
    enabled = true
  }

  lifecycle {
    ignore_changes = [ttl]
  }
}

resource "aws_dynamodb_table" "registration_history" {
  name           = "registrations_history"
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
}

resource "aws_dynamodb_table" "waiting_list" {
  name           = "waiting_list"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Env = "prod"
  }
}


output "dynamo_registration_table" {
  value = aws_dynamodb_table.registrations
}
output "dynamo_registration_history_table" {
  value = aws_dynamodb_table.registration_history
}
output "dynamo_waiting_list_table" {
  value = aws_dynamodb_table.waiting_list
}

# Add autoscaling for the whole table
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

# Autoscaling for the GSIs
resource "aws_appautoscaling_target" "read_target_gsi_competition_id" {
  max_capacity       = 100
  min_capacity       = 5
  resource_id        = "table/${aws_dynamodb_table.registrations.name}/index/registrations_index_competition_id"
  scalable_dimension = "dynamodb:index:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_target" "write_target_gsi_competition_id" {
  max_capacity       = 100
  min_capacity       = 5
  resource_id        = "table/${aws_dynamodb_table.registrations.name}/index/registrations_index_competition_id"
  scalable_dimension = "dynamodb:index:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "read_policy" {
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.read_target_gsi_competition_id.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.read_target_gsi_competition_id.resource_id
  scalable_dimension = aws_appautoscaling_target.read_target_gsi_competition_id.scalable_dimension
  service_namespace  = aws_appautoscaling_target.read_target_gsi_competition_id.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }

    target_value       = 85
    scale_in_cooldown  = 30
    scale_out_cooldown = 30
  }

  depends_on = [aws_appautoscaling_target.read_target_gsi_competition_id]
}

resource "aws_appautoscaling_policy" "write_policy" {
  name               = "DynamoDBWriteCapacityUtilization:${aws_appautoscaling_target.write_target_gsi_competition_id.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.write_target_gsi_competition_id.resource_id
  scalable_dimension = aws_appautoscaling_target.write_target_gsi_competition_id.scalable_dimension
  service_namespace  = aws_appautoscaling_target.write_target_gsi_competition_id.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }

    target_value       = 85
    scale_in_cooldown  = 30
    scale_out_cooldown = 30
  }

  depends_on = [aws_appautoscaling_target.write_target_gsi_competition_id]
}

resource "aws_appautoscaling_target" "read_target_gsi_user_id" {
  max_capacity       = 100
  min_capacity       = 5
  resource_id        = "table/${aws_dynamodb_table.registrations.name}/index/registrations_index_user_id"
  scalable_dimension = "dynamodb:index:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_target" "write_target_gsi_user_id" {
  max_capacity       = 100
  min_capacity       = 5
  resource_id        = "table/${aws_dynamodb_table.registrations.name}/index/registrations_index_user_id"
  scalable_dimension = "dynamodb:index:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "read_policy_user" {
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.read_target_gsi_user_id.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.read_target_gsi_user_id.resource_id
  scalable_dimension = aws_appautoscaling_target.read_target_gsi_user_id.scalable_dimension
  service_namespace  = aws_appautoscaling_target.read_target_gsi_user_id.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }

    target_value       = 85
    scale_in_cooldown  = 30
    scale_out_cooldown = 30
  }

  depends_on = [aws_appautoscaling_target.read_target_gsi_user_id]
}

resource "aws_appautoscaling_policy" "write_policy_user" {
  name               = "DynamoDBWriteCapacityUtilization:${aws_appautoscaling_target.write_target_gsi_user_id.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.write_target_gsi_user_id.resource_id
  scalable_dimension = aws_appautoscaling_target.write_target_gsi_user_id.scalable_dimension
  service_namespace  = aws_appautoscaling_target.write_target_gsi_user_id.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }

    target_value       = 85
    scale_in_cooldown  = 30
    scale_out_cooldown = 30
  }

  depends_on = [aws_appautoscaling_target.write_target_gsi_user_id]
}

