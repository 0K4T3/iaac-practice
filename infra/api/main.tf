provider "aws" {
  region = "us-east-1"

  access_key = "dummy_access_key"
  secret_key = "dummmy_secret_key"

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    apigateway = "http://localhost:4566"
    lambda = "http://localhost:4566"
  }
}

resource "aws_lambda_function" "test_function" {
    function_name = "test_function"
    handler = "app.lambda_handler"
    filename = "./function.zip"
    runtime = "python3.8"
    role = "dummy_role"

    environment {
      variables = {
        AWS_ENDPOINT = "http://localhost:4566/"
      }
    }
}

resource "aws_api_gateway_rest_api" "test_api" {
    name = "test_api"
}

resource "aws_api_gateway_resource" "test_resource" {
    rest_api_id = aws_api_gateway_rest_api.test_api.id
    parent_id = aws_api_gateway_rest_api.test_api.root_resource_id
    path_part = "{proxy+}"
}

resource "aws_api_gateway_method" "test_method" {
    rest_api_id = aws_api_gateway_rest_api.test_api.id
    resource_id = aws_api_gateway_resource.test_resource.id
    http_method = "ANY"
    authorization = "NONE"
}

resource "aws_api_gateway_integration" "test_integration" {
    rest_api_id = aws_api_gateway_rest_api.test_api.id
    resource_id = aws_api_gateway_method.test_method.resource_id
    http_method = aws_api_gateway_method.test_method.http_method

    integration_http_method = "ANY"
    type = "AWS_PROXY"
    uri = aws_lambda_function.test_function.invoke_arn
}

resource "aws_api_gateway_deployment" "test_deployment" {
    depends_on = [
        aws_api_gateway_integration.test_integration,
    ]

    rest_api_id = aws_api_gateway_rest_api.test_api.id
    stage_name = "test"
}

resource "aws_lambda_permission" "test_permission" {
    statement_id = "AllowAPIGatewayInvoke"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.test_function.function_name
    principal = "apigateway.amazonaws.com"

    source_arn = "${aws_api_gateway_rest_api.test_api.execution_arn}/*/*"
}

output "rest_api_id" {
  description = "REST API id"
  value       = aws_api_gateway_rest_api.test_api.id
}

output "api_endpoint" {
  description = "REST API id"
  value       = "/restapis/${aws_api_gateway_rest_api.test_api.id}/test/_user_request_"
}
