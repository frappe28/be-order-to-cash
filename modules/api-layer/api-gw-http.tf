locals {
  api_body = templatefile("${path.module}/swaggers/api-layer-swagger.yml", {
    region                  = var.region
    account_id              = var.account_id
    create_checkout_session = var.create_checkout_session_name
    set_payment_method      = var.set_payment_method_name
    confirm_checkout         = var.confirm_checkout_name
    get_order_status         = var.get_order_status_name
    get_price                = var.get_price_name
  })
}

resource "aws_api_gateway_rest_api" "api" {
  name = var.webapp_api_name
  body = local.api_body

  tags = {
    Project     = var.project
    Environment = var.env
  }
}

resource "aws_api_gateway_deployment" "api" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  triggers = {
    redeployment = sha1(local.api_body)
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "default" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.api.id
  stage_name    = var.env
}
