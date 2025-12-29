resource "aws_apigatewayv2_api" "http_api" {
  name          = "${var.project}-${var.env}-webapp-api"
  protocol_type = "HTTP"
  body = templatefile("${path.module}/swaggers/api-layer-swagger.yml", {
    region                  = var.region
    account_id              = var.account_id
    create_checkout_session = var.create_checkout_session_lambda_name
    set_payment_method      = var.set_payment_method_lambda_name
    confirm_checkout         = var.confirm_checkout_lambda_name
    get_order_status         = var.get_order_status_lambda_name
  })

  tags = {
    Project     = var.project
    Environment = var.env
  }
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = var.env
  auto_deploy = true
}
