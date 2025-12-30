data "archive_file" "zuora_validate_price" {
  type        = "zip"
  source_file = "${path.module}/lambda-src/validate_zuora_price.py"
  output_path = "${path.module}/lambda-src/validate_zuora_price.zip"
}

data "aws_iam_policy_document" "lambda_assume_role_zuora_validate" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_logs_zuora_validate" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:${var.region}:${var.account_id}:*"]
  }
}

data "aws_iam_policy_document" "lambda_events_zuora_validate" {
  statement {
    actions   = ["events:PutEvents"]
    resources = [aws_cloudwatch_event_bus.ingestion.arn]
  }
}

resource "aws_iam_role" "zuora_validate_price" {
  name               = "${local.zuora_validate_lambda_name}-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_zuora_validate.json
}

resource "aws_iam_role_policy" "zuora_validate_price_logs" {
  name   = "${local.zuora_validate_lambda_name}-logs"
  role   = aws_iam_role.zuora_validate_price.id
  policy = data.aws_iam_policy_document.lambda_logs_zuora_validate.json
}

resource "aws_iam_role_policy" "zuora_validate_price_events" {
  name   = "${local.zuora_validate_lambda_name}-events"
  role   = aws_iam_role.zuora_validate_price.id
  policy = data.aws_iam_policy_document.lambda_events_zuora_validate.json
}

resource "aws_lambda_function" "zuora_validate_price" {
  function_name    = local.zuora_validate_lambda_name
  handler          = "validate_zuora_price.handler"
  runtime          = "python3.11"
  role             = aws_iam_role.zuora_validate_price.arn
  filename         = data.archive_file.zuora_validate_price.output_path
  source_code_hash = data.archive_file.zuora_validate_price.output_base64sha256

  environment {
    variables = {
      EVENT_BUS_NAME = aws_cloudwatch_event_bus.ingestion.name
    }
  }
}
