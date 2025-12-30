resource "aws_cloudwatch_event_rule" "zuora_price_validated" {
  name           = "${var.project}-${var.env}-zuora-price-validated"

  event_pattern = jsonencode({
    source      = ["zuora.validation"]
    detail-type = ["ZuoraPriceValidated"]
  })
}

resource "aws_cloudwatch_event_target" "normalize_zuora_price" {
  rule           = aws_cloudwatch_event_rule.zuora_price_validated.name
  target_id      = "normalize-zuora-price"
  arn            = aws_lambda_function.normalize_zuora_price.arn
}

resource "aws_lambda_permission" "eventbridge_invoke_normalize" {
  statement_id  = "AllowExecutionFromEventBridge-normalize-zuora-price"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.normalize_zuora_price.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.zuora_price_validated.arn
}
