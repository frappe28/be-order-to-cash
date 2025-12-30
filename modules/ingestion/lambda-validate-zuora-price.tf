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
    resources = ["arn:aws:events:${var.region}:${var.account_id}:event-bus/default"]
  }
}

resource "aws_iam_role" "zuora_validate_price" {
  name               = var.validate_zuora_price_name
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_zuora_validate.json
}

resource "aws_iam_role_policy" "zuora_validate_price_logs" {
  name   = var.validate_zuora_price_name
  role   = aws_iam_role.zuora_validate_price.id
  policy = data.aws_iam_policy_document.lambda_logs_zuora_validate.json
}

resource "aws_iam_role_policy" "zuora_validate_price_events" {
  name   = var.validate_zuora_price_name
  role   = aws_iam_role.zuora_validate_price.id
  policy = data.aws_iam_policy_document.lambda_events_zuora_validate.json
}

resource "aws_lambda_function" "zuora_validate_price" {
  function_name    = var.validate_zuora_price_name
  handler          = "validate_zuora_price.handler"
  runtime          = "python3.11"
  role             = aws_iam_role.zuora_validate_price.arn
  filename         = data.archive_file.zuora_validate_price.output_path
  source_code_hash = data.archive_file.zuora_validate_price.output_base64sha256

  environment {
    variables = {
      EVENT_BUS_NAME = "default"
    }
  }
}
