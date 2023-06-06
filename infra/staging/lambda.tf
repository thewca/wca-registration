resource "aws_lambda_function" "task_termination" {
  filename         = "${path.module}/function.zip"
  source_code_hash = filebase64sha256("${path.module}/function.zip")
  function_name    = "task_termination_function"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  memory_size      = 128
  timeout          = 60

  tags = {
    Env = "staging"
  }
}

resource "aws_cloudwatch_event_rule" "scheduled_event" {
  name        = "task_termination_schedule"
  description = "Schedule for running the task termination Lambda function"
  schedule_expression = "rate(30 minutes)"
  tags = {
    Env = "staging"
  }
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.scheduled_event.name
  target_id = "task_termination_target"
  arn       = aws_lambda_function.task_termination.arn
}

resource "aws_iam_role" "lambda_role" {
  name = "task_termination_lambda_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  tags = {
    Env = "staging"
  }
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "task_termination_lambda_policy"
  description = "Policy for task termination Lambda function"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecs:ListTasks",
        "ecs:DescribeTasks",
        "ecs:StopTask"
      ],
      "Resource": "*"
    }
  ]
}
EOF
  tags = {
    Env = "staging"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_policy.arn
  role       = aws_iam_role.lambda_role.name
}