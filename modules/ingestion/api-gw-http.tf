resource "aws_api_gateway_rest_api" "ingestion_rest_api" {
  name = var.ingestion_rest_api_name

  tags = {
    Project     = var.project
    Environment = var.env
  }
}

resource "aws_api_gateway_resource" "webhooks" {
  rest_api_id = aws_api_gateway_rest_api.ingestion_rest_api.id
  parent_id   = aws_api_gateway_rest_api.ingestion_rest_api.root_resource_id
  path_part   = "webhooks"
}

resource "aws_api_gateway_resource" "zuora" {
  rest_api_id = aws_api_gateway_rest_api.ingestion_rest_api.id
  parent_id   = aws_api_gateway_resource.webhooks.id
  path_part   = "zuora"
}

resource "aws_api_gateway_method" "zuora_webhook_post" {
  rest_api_id   = aws_api_gateway_rest_api.ingestion_rest_api.id
  resource_id   = aws_api_gateway_resource.zuora.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "zuora_webhook" {
  rest_api_id             = aws_api_gateway_rest_api.ingestion_rest_api.id
  resource_id             = aws_api_gateway_resource.zuora.id
  http_method             = aws_api_gateway_method.zuora_webhook_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.zuora_webhook.invoke_arn
}

resource "aws_api_gateway_deployment" "ingestion" {
  rest_api_id = aws_api_gateway_rest_api.ingestion_rest_api.id
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.webhooks.id,
      aws_api_gateway_resource.zuora.id,
      aws_api_gateway_method.zuora_webhook_post.id,
      aws_api_gateway_integration.zuora_webhook.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.zuora_webhook,
  ]
}

resource "aws_api_gateway_stage" "ingestion_default" {
  rest_api_id   = aws_api_gateway_rest_api.ingestion_rest_api.id
  deployment_id = aws_api_gateway_deployment.ingestion.id
  stage_name    = "${var.env}"
}

resource "aws_lambda_permission" "zuora_webhook_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway-zuora-webhook"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.zuora_webhook.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.ingestion_rest_api.execution_arn}/*/POST/webhooks/zuora"
}
