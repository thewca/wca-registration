resource "aws_cloudwatch_log_group" "this" {
  name = var.name_prefix
}

locals {
  app_environment = [
    {
      name  = "HOST"
      value = var.host
    },
    {
      name  = "WCA_HOST"
      value = var.wca_host
    },
    {
      name = "AWS_REGION"
      value = var.region
    },
    {
      name = "QUEUE_NAME",
      value = var.shared_resources.queue.name
    },
    {
      name = "VAULT_ADDR"
      value = var.vault_address
    },
    {
      name = "VAULT_APPLICATION",
      value = "wca-registration-production"
    },
    {
      name = "REGISTRATION_LIVE_SITE",
      value = "true"
    },
    {
      name = "TASK_ROLE"
      value = aws_iam_role.task_role.name
    },
    {
      name = "DYNAMO_REGISTRATIONS_TABLE",
      value = var.shared_resources.dynamo_registration_table.name
    },
    {
      name = "REGISTRATION_HISTORY_DYNAMO_TABLE",
      value = var.shared_resources.dynamo_registration_history_table.name
    },
    {
      name = "WAITING_LIST_DYNAMO_TABLE",
      value = var.shared_resources.dynamo_waiting_list_table.name
    },
    {
      name = "REDIS_URL"
      value = "redis://${var.shared_resources.aws_elasticache_cluster.cache_nodes.0.address}:${var.shared_resources.aws_elasticache_cluster.cache_nodes.0.port}"
    },
  ]
}

data "aws_iam_policy_document" "task_assume_role_policy" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "task_execution_role" {
  name               = "${var.name_prefix}-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.task_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "task_execution_role_attachment" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "task_role" {
  name               = "${var.name_prefix}-task-role"
  assume_role_policy = data.aws_iam_policy_document.task_assume_role_policy.json
}

data "aws_iam_policy_document" "task_policy" {
  statement {
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel",
    ]

    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:Query",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:DescribeTable",
    ]
    resources = [var.shared_resources.dynamo_registration_table.arn, "${var.shared_resources.dynamo_registration_table.arn}/*",
                 var.shared_resources.dynamo_registration_history_table.arn, "${var.shared_resources.dynamo_registration_history_table.arn}/*",
                 var.shared_resources.dynamo_waiting_list_table.arn, "${var.shared_resources.dynamo_waiting_list_table.arn}/*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:ListTables",
    ]
    resources = ["arn:aws:dynamodb:us-west-2:285938427530:table/*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "sqs:SendMessage",
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl"
    ]
    resources = [var.shared_resources.queue.arn]
  }
}

resource "aws_iam_role_policy" "task_policy" {
  role   = aws_iam_role.task_role.name
  policy = data.aws_iam_policy_document.task_policy.json
}

resource "aws_ecs_task_definition" "this" {
  family = var.name_prefix

  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]

  # We configure the roles to allow `aws ecs execute-command` into a task,
  # as in https://aws.amazon.com/blogs/containers/new-using-amazon-ecs-exec-access-your-containers-fargate-ec2
  execution_role_arn = aws_iam_role.task_execution_role.arn
  task_role_arn      = aws_iam_role.task_role.arn

  cpu = "256"
  memory = "256"

  container_definitions = jsonencode([
    {
      name              = "worker"
      image             = "${aws_ecr_repository.this.repository_url}:latest"
      cpu    = 256
      memory = 256
      portMappings = []
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = var.region
          awslogs-stream-prefix = var.name_prefix
        }
      }
      environment = local.app_environment
      healthCheck       = {
        command            = ["CMD-SHELL", "pgrep ruby || exit 1"]
        interval           = 30
        retries            = 3
        startPeriod        = 60
        timeout            = 5
      }
    }
  ])

  tags = {
    Name = var.name_prefix
  }
}



data "aws_ecs_task_definition" "this" {
  task_definition = aws_ecs_task_definition.this.family
}

resource "aws_ecs_service" "this" {
  name    = var.name_prefix
  cluster = var.shared_resources.ecs_cluster.id
  # During deployment a new task revision is created with modified
  # container image, so we want use data.aws_ecs_task_definition to
  # always point to the active task definition
  task_definition                    = data.aws_ecs_task_definition.this.arn
  desired_count                      = 1
  scheduling_strategy                = "REPLICA"
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 50
  health_check_grace_period_seconds  = 0

  capacity_provider_strategy {
    capacity_provider = var.shared_resources.capacity_provider.name
    weight            = 1
  }

  enable_execute_command = true

  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }

  ordered_placement_strategy {
    type  = "spread"
    field = "instanceId"
  }

  network_configuration {
    security_groups = [var.shared_resources.cluster_security.id]
    subnets         = var.shared_resources.private_subnets
  }

  deployment_controller {
    type = "ECS"
  }

  tags = {
    Name = var.name_prefix
  }

  lifecycle {
    ignore_changes = [
      # The desired count is modified by Application Auto Scaling
      desired_count,
      # The target group changes during Blue/Green deployment
      load_balancer,
    ]
  }

}

resource "aws_appautoscaling_target" "this" {
  service_namespace  = "ecs"
  resource_id        = "service/${var.shared_resources.ecs_cluster.name}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = 1
  max_capacity       = 5
}

resource "aws_appautoscaling_policy" "this" {
  name               = var.name_prefix
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this.resource_id
  scalable_dimension = aws_appautoscaling_target.this.scalable_dimension
  service_namespace  = aws_appautoscaling_target.this.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
      # predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    # target_value = 80
    target_value = 65
  }

  depends_on = [aws_appautoscaling_target.this]
}
