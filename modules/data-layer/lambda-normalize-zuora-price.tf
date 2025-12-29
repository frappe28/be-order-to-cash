data "archive_file" "normalize_zuora_price" {
  type        = "zip"
  source_file = "${path.module}/lambda-src/normalize_zuora_price.py"
  output_path = "${path.module}/lambda-src/normalize_zuora_price.zip"
}

data "aws_iam_policy_document" "lambda_assume_role_normalize" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_logs_normalize" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:${var.region}:${var.account_id}:*"]
  }
}

data "aws_iam_policy_document" "lambda_dynamodb_normalize" {
  statement {
    actions = ["dynamodb:PutItem"]
    resources = [
      aws_dynamodb_table.pricing.arn,
    ]
  }
}

resource "aws_iam_role" "normalize_zuora_price" {
  name               = "${local.normalize_lambda_name}-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_normalize.json
}

resource "aws_iam_role_policy" "normalize_zuora_price_logs" {
  name   = "${local.normalize_lambda_name}-logs"
  role   = aws_iam_role.normalize_zuora_price.id
  policy = data.aws_iam_policy_document.lambda_logs_normalize.json
}

resource "aws_iam_role_policy" "normalize_zuora_price_dynamodb" {
  name   = "${local.normalize_lambda_name}-dynamodb"
  role   = aws_iam_role.normalize_zuora_price.id
  policy = data.aws_iam_policy_document.lambda_dynamodb_normalize.json
}

resource "aws_lambda_function" "normalize_zuora_price" {
  function_name    = local.normalize_lambda_name
  handler          = "normalize_zuora_price.handler"
  runtime          = "python3.12"
  role             = aws_iam_role.normalize_zuora_price.arn
  filename         = data.archive_file.normalize_zuora_price.output_path
  source_code_hash = data.archive_file.normalize_zuora_price.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.pricing.name
    }
  }
}
