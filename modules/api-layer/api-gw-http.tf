resource "aws_apigatewayv2_api" "http_api" {
  name          = "${var.project}-${var.env}-api-layer-webapp-api"
  protocol_type = "HTTP"
  body = templatefile("${path.module}/swaggers/api-layer-swagger.yml", {
    region                  = var.region
    account_id              = var.account_id
    create_checkout_session = "${var.project}-${var.env}-api-layer-create-checkout-session"
    set_payment_method      = "${var.project}-${var.env}-api-layer-set-payment-method"
    confirm_checkout         = "${var.project}-${var.env}-api-layer-confirm-checkout"
    get_order_status         = "${var.project}-${var.env}-api-layer-get-order-status"
  })

  tags = {
    Project     = var.project
    Environment = var.env
  }
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "${var.project}-${var.env}-api-layer"
  auto_deploy = true
}
