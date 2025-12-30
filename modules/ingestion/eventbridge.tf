resource "aws_cloudwatch_event_bus" "ingestion" {
  name = local.ingestion_event_bus_name
}

resource "aws_sqs_queue" "ingestion_dlq" {
  name = local.ingestion_dlq_name
}

data "aws_iam_policy_document" "ingestion_dlq" {
  statement {
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.ingestion_dlq.arn]
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudwatch_event_rule.zuora_webhook_received.arn]
    }
  }
}

resource "aws_sqs_queue_policy" "ingestion_dlq" {
  queue_url = aws_sqs_queue.ingestion_dlq.id
  policy    = data.aws_iam_policy_document.ingestion_dlq.json
}

resource "aws_cloudwatch_event_rule" "zuora_webhook_received" {
  name           = "${var.project}-${var.env}-zuora-webhook-received"
  event_bus_name = aws_cloudwatch_event_bus.ingestion.name

  event_pattern = jsonencode({
    source      = ["zuora.webhook"]
    detail-type = ["ZuoraPriceWebhookReceived"]
  })
}

resource "aws_cloudwatch_event_target" "zuora_validation" {
  rule           = aws_cloudwatch_event_rule.zuora_webhook_received.name
  event_bus_name = aws_cloudwatch_event_bus.ingestion.name
  target_id      = "zuora-validation"
  arn            = aws_lambda_function.zuora_validate_price.arn

  retry_policy {
    maximum_retry_attempts       = 3
    maximum_event_age_in_seconds = 3600
  }

  dead_letter_config {
    arn = aws_sqs_queue.ingestion_dlq.arn
  }
}

resource "aws_lambda_permission" "eventbridge_invoke_validation" {
  statement_id  = "AllowExecutionFromEventBridge-zuora-validation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.zuora_validate_price.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.zuora_webhook_received.arn
}

resource "aws_cloudwatch_event_rule" "zuora_price_validated" {
  name           = "${var.project}-${var.env}-zuora-price-validated"
  event_bus_name = aws_cloudwatch_event_bus.ingestion.name

  event_pattern = jsonencode({
    source      = ["zuora.validation"]
    detail-type = ["ZuoraPriceValidated"]
  })
}

resource "aws_cloudwatch_event_target" "zuora_normalize" {
  rule           = aws_cloudwatch_event_rule.zuora_price_validated.name
  event_bus_name = aws_cloudwatch_event_bus.ingestion.name
  target_id      = "zuora-normalize"
  arn            = aws_lambda_function.zuora_normalize_price.arn

  retry_policy {
    maximum_retry_attempts       = 3
    maximum_event_age_in_seconds = 3600
  }

  dead_letter_config {
    arn = aws_sqs_queue.ingestion_dlq.arn
  }
}

resource "aws_lambda_permission" "eventbridge_invoke_normalize" {
  statement_id  = "AllowExecutionFromEventBridge-zuora-normalize"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.zuora_normalize_price.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.zuora_price_validated.arn
}
