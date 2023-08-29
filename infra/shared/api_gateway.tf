resource "aws_api_gateway_rest_api" "this" {
  name        = "wca-registration-polling-api"
  description = "The API to Poll for updates"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  lifecycle {
    create_before_destroy = true
  }
}

output "api_gateway" {
  value = aws_api_gateway_rest_api.this
}

output "api_gateway_url" {
  value = aws_api_gateway_deployment.this.invoke_url
}
