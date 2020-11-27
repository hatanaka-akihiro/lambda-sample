resource "aws_iam_role" "myLambdaFunction-role" {
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "lambda.amazonaws.com"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
  force_detach_policies = false
  name                  = var.lambda_role_name
  path                  = "/service-role/"
}

data "aws_iam_policy" "AWSLambdaBasicExecutionRole" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda-basic-attach" {
  policy_arn = data.aws_iam_policy.AWSLambdaBasicExecutionRole.arn
  role       = aws_iam_role.myLambdaFunction-role.name
}

data "archive_file" "lambda-src-zip" {
  type        = "zip"
  source_dir  = "lambda-src"
  output_path = "lambda/myLambdaFunction.zip"
}

resource "aws_lambda_function" "myLambdaFunction" {
  function_name    = var.lambda_function_name
  handler          = "index.handler"
  runtime          = "nodejs12.x"
  role             = aws_iam_role.myLambdaFunction-role.arn
  source_code_hash = filebase64sha256(data.archive_file.lambda-src-zip.output_path)
  timeout          = 30
  filename         = data.archive_file.lambda-src-zip.output_path

  environment {
    variables = {
    }
  }
}

resource "aws_lambda_permission" "invoke" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.myLambdaFunction.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.myLambdaFunction-API.execution_arn}/*/GET/${var.lambda_function_name}"
}

resource "aws_api_gateway_rest_api" "myLambdaFunction-API" {
  name        = var.api_name
  description = "Created by AWS Lambda"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "myKintoneFunction-API-Resource" {
  rest_api_id = aws_api_gateway_rest_api.myLambdaFunction-API.id
  parent_id   = aws_api_gateway_rest_api.myLambdaFunction-API.root_resource_id
  path_part   = var.api_path
}

resource "aws_api_gateway_method" "get" {
  rest_api_id   = aws_api_gateway_rest_api.myLambdaFunction-API.id
  resource_id   = aws_api_gateway_resource.myLambdaFunction-API-Resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "response_200" {
  http_method = aws_api_gateway_method.get.http_method
  resource_id = aws_api_gateway_resource.myLambdaFunction-API-Resource.id
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {}
  rest_api_id         = aws_api_gateway_rest_api.myLambdaFunction-API.id
  status_code         = "200"
}

resource "aws_api_gateway_integration" "myLambdaFunction-Integration" {
  rest_api_id             = aws_api_gateway_rest_api.myLambdaFunction-API.id
  resource_id             = aws_api_gateway_resource.myLambdaFunction-API-Resource.id
  http_method             = aws_api_gateway_method.get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  content_handling        = "CONVERT_TO_TEXT"
  uri                     = aws_lambda_function.myLambdaFunction.invoke_arn
}

resource "aws_api_gateway_integration_response" "myLambdaFunction-IntegrationResponse" {
  rest_api_id = aws_api_gateway_rest_api.myLambdaFunction-API.id
  resource_id = aws_api_gateway_resource.myLambdaFunction-API-Resource.id
  http_method = aws_api_gateway_method.get.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code
  response_templates = {
    "application/json" = ""
  }

  depends_on = [aws_api_gateway_integration.myLambdaFunction-Integration]
}

resource "aws_api_gateway_deployment" "myLambdaFunction-Deployment" {
  depends_on = [aws_api_gateway_integration.myLambdaFunction-Integration]

  rest_api_id = aws_api_gateway_rest_api.myLambdaFunction-API.id
  stage_name  = var.api_stage

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_region" "current" {}

output "api_url" {
  value = "https://${aws_api_gateway_rest_api.myLambdaFunction-API.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${var.api_stage}/${var.api_path}"
}