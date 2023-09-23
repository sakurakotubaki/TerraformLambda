provider "aws" {
  region  = "ap-northeast-1"  # 東京リージョン
  profile = "default"  # デフォルトのプロファイルを使用
}

data "archive_file" "hello_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_function/hello.js"
  output_path = "${path.module}/hello.zip"
}

resource "aws_lambda_function" "hello" {
  function_name = "hello_function"
  handler       = "hello.handler"
  role          = aws_iam_role.lambda_exec.arn
  filename      = data.archive_file.hello_zip.output_path
  source_code_hash = filebase64sha256(data.archive_file.hello_zip.output_path)
  runtime       = "nodejs18.x"
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

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

resource "aws_api_gateway_rest_api" "my_api" {
  name        = "my-api"
  description = "My API"
}

resource "aws_api_gateway_resource" "my_resource" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id   = aws_api_gateway_rest_api.my_api.root_resource_id
  path_part   = "myresource"
}

resource "aws_api_gateway_method" "my_method" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.my_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "my_integration" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.my_resource.id
  http_method = aws_api_gateway_method.my_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.hello.invoke_arn
}

resource "aws_api_gateway_deployment" "my_deployment" {
  depends_on = [aws_api_gateway_integration.my_integration]

  rest_api_id = aws_api_gateway_rest_api.my_api.id
  stage_name  = "test"
}

output "invoke_url" {
  value = "${aws_api_gateway_rest_api.my_api.execution_arn}/test/myresource"
}

