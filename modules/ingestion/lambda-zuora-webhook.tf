data "archive_file" "zuora_webhook" {
  type        = "zip"
  source_file = "${path.module}/lambda-src/zuora_webhook.py"
  output_path = "${path.module}/lambda-src/zuora_webhook.zip"
}

data "aws_iam_policy_document" "lambda_assume_role_zuora_webhook" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_logs_zuora_webhook" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:${var.region}:${var.account_id}:*"]
  }
}

data "aws_iam_policy_document" "lambda_events_zuora_webhook" {
  statement {
    actions   = ["events:PutEvents"]
    resources = [aws_cloudwatch_event_bus.ingestion.arn]
  }
}

resource "aws_iam_role" "zuora_webhook" {
  name               = "${local.zuora_webhook_lambda_name}-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_zuora_webhook.json
}

resource "aws_iam_role_policy" "zuora_webhook_logs" {
  name   = "${local.zuora_webhook_lambda_name}-logs"
  role   = aws_iam_role.zuora_webhook.id
  policy = data.aws_iam_policy_document.lambda_logs_zuora_webhook.json
}

resource "aws_iam_role_policy" "zuora_webhook_events" {
  name   = "${local.zuora_webhook_lambda_name}-events"
  role   = aws_iam_role.zuora_webhook.id
  policy = data.aws_iam_policy_document.lambda_events_zuora_webhook.json
}

resource "aws_lambda_function" "zuora_webhook" {
  function_name    = local.zuora_webhook_lambda_name
  handler          = "zuora_webhook.handler"
  runtime          = "python3.11"
  role             = aws_iam_role.zuora_webhook.arn
  filename         = data.archive_file.zuora_webhook.output_path
  source_code_hash = data.archive_file.zuora_webhook.output_base64sha256

  environment {
    variables = {
      EVENT_BUS_NAME = aws_cloudwatch_event_bus.ingestion.name
    }
  }
}
