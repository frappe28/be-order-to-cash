resource "aws_apigatewayv2_api" "ingestion_http_api" {
  name          = local.ingestion_http_api_name
  protocol_type = "HTTP"

  tags = {
    Project     = var.project
    Environment = var.env
  }
}

resource "aws_apigatewayv2_integration" "zuora_webhook" {
  api_id                 = aws_apigatewayv2_api.ingestion_http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.zuora_webhook.arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "zuora_webhook" {
  api_id    = aws_apigatewayv2_api.ingestion_http_api.id
  route_key = local.ingestion_webhook_route_key
  target    = "integrations/${aws_apigatewayv2_integration.zuora_webhook.id}"
}

resource "aws_apigatewayv2_stage" "ingestion_default" {
  api_id      = aws_apigatewayv2_api.ingestion_http_api.id
  name        = var.env
  auto_deploy = true
}

resource "aws_lambda_permission" "zuora_webhook_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway-zuora-webhook"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.zuora_webhook.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.ingestion_http_api.execution_arn}/*/*"
}
