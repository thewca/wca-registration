resource "aws_cloudwatch_log_group" "this" {
  name = "wca-registration-staging"
}

locals {
  app_environment = [
    {
      name  = "WCA_HOST"
      value = var.wca_host
    },
    {
      name = "AWS_REGION"
      value = var.region
    },
    {
      name = "VAULT_ADDR"
      value = var.vault_address
    },
    {
      name = "QUEUE_URL",
      value = aws_sqs_queue.this.url
    },
    {
      name = "TASK_ROLE"
      value = aws_iam_role.task_role.name
    },
    {
      name = "CODE_ENVIRONMENT"
      value = "staging"
    },
    {
      name = "PROMETHEUS_EXPORTER"
      value = var.prometheus_address
    }
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

  tags = {
    Env = "staging"
  }
}

resource "aws_iam_role_policy_attachment" "task_execution_role_attachment" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "task_role" {
  name               = "${var.name_prefix}-task-role"
  assume_role_policy = data.aws_iam_policy_document.task_assume_role_policy.json

  tags = {
    Env = "staging"
  }
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
    resources = [aws_dynamodb_table.registrations.arn,"${aws_dynamodb_table.registrations.arn}/*"]
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
    resources = [aws_sqs_queue.this.arn]
  }
}

resource "aws_iam_role_policy" "task_policy" {
  role   = aws_iam_role.task_role.name
  policy = data.aws_iam_policy_document.task_policy.json
}

resource "aws_lb_target_group" "this" {
  name        = "wca-registration-staging"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  deregistration_delay = 10

  health_check {
    interval            = 10
    path                = "/healthcheck"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = 200
  }
  tags = {
    Name = var.name_prefix
    Env = "staging"
  }
}

resource "aws_ecs_task_definition" "this" {
  family = var.name_prefix

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  runtime_platform {
    operating_system_family = "LINUX"
  }

  # We configure the roles to allow `aws ecs execute-command` into a task,
  # as in https://aws.amazon.com/blogs/containers/new-using-amazon-ecs-exec-access-your-containers-fargate-ec2
  execution_role_arn = aws_iam_role.task_execution_role.arn
  task_role_arn      = aws_iam_role.task_role.arn

  cpu = "1024"
  memory = "2048"

  container_definitions = jsonencode([
    {
      name              = "staging-handler"
      image             = "${var.registration-handler-ecr-repository}:staging"
      portMappings = [
        {
          # The hostPort is automatically set for awsvpc network mode,
          # see https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_PortMapping.html#ECS-Type-PortMapping-hostPort
          containerPort = 3000
          protocol      = "tcp"
        },
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "${var.name_prefix}-handler"
        }
      }
      environment = local.app_environment
      healthCheck       = {
        command            = ["CMD-SHELL", "curl -f http://localhost:3000/healthcheck || exit 1"]
        interval           = 30
        retries            = 3
        startPeriod        = 60
        timeout            = 5
      }
    },
    {
      name              = "staging-worker"
      image             = "${var.registration-worker-ecr-repository}:staging"
      portMappings = []
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "${var.name_prefix}-worker"
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
    Env = "staging"
  }
}


data "aws_ecs_task_definition" "this" {
  task_definition = aws_ecs_task_definition.this.family
}
