resource "aws_lambda_function" "registration_status_lambda" {
  filename         = "./lambda/registration_status.zip"
  function_name    = "${var.name_prefix}-poller-lambda-prod"
  role             = aws_iam_role.lambda_role.arn
  handler          = "registration_status.lambda_handler"
  runtime          = "ruby3.2"
  source_code_hash = filebase64sha256("./lambda/registration_status.zip")
  environment {
    variables = {
      QUEUE_URL = var.shared_resources.queue.url
      CODE_ENVIRONMENT = "production"
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "${var.name_prefix}-lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_exec_policy_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_permission" "this" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.registration_status_lambda.function_name
  principal     = "apigateway.amazonaws.com"
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:Query",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:DescribeTable",
    ]
    resources = [var.shared_resources.dynamo_registration_table.arn, "${var.shared_resources.dynamo_registration_table.arn}/*"]
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
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl"
    ]
    resources = [var.shared_resources.queue.arn]
  }
}

resource "aws_iam_role_policy" "lambda_policy_attachment" {
  role   = aws_iam_role.lambda_role.name
  policy = data.aws_iam_policy_document.lambda_policy.json
}

resource "aws_api_gateway_resource" "prod" {
  rest_api_id = var.shared_resources.api_gateway.id
  parent_id   = var.shared_resources.api_gateway.root_resource_id
  path_part   = "prod"
}

resource "aws_api_gateway_method" "poll_registration_status_method" {
  rest_api_id   = var.shared_resources.api_gateway.id
  resource_id   = aws_api_gateway_resource.prod.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "poll_registration_integration" {
  rest_api_id = var.shared_resources.api_gateway.id
  resource_id = aws_api_gateway_resource.prod.id
  http_method = aws_api_gateway_method.poll_registration_status_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.registration_status_lambda.invoke_arn
}

resource "aws_api_gateway_method_response" "registration_status_method" {
  rest_api_id = var.shared_resources.api_gateway.id
  resource_id = aws_api_gateway_resource.prod.id
  http_method = aws_api_gateway_method.poll_registration_status_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Content-Type" = true
  }
}

resource "aws_api_gateway_integration_response" "registration_status_integration_response" {
  rest_api_id = var.shared_resources.api_gateway.id
  resource_id = aws_api_gateway_resource.prod.id
  http_method = aws_api_gateway_method.poll_registration_status_method.http_method
  status_code = aws_api_gateway_method_response.registration_status_method.status_code

  response_templates = {
    "application/json" = jsonencode({
      status = "Registration Status"
      queue_count = "Queue Count"
    })
  }
  depends_on = [aws_api_gateway_resource.prod, aws_api_gateway_method.poll_registration_status_method, aws_api_gateway_method_response.registration_status_method, aws_api_gateway_integration.poll_registration_integration]
}
resource "aws_api_gateway_deployment" "this" {
  rest_api_id = var.shared_resources.api_gateway.id

  lifecycle {
    create_before_destroy = true
  }
  depends_on = [aws_api_gateway_method.poll_registration_status_method, aws_api_gateway_integration.poll_registration_integration]
}
