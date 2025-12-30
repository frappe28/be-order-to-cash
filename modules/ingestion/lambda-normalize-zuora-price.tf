data "archive_file" "zuora_normalize_price" {
  type        = "zip"
  source_file = "${path.module}/lambda-src/normalize_zuora_price.py"
  output_path = "${path.module}/lambda-src/normalize_zuora_price.zip"
}

data "aws_iam_policy_document" "lambda_assume_role_zuora_normalize" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_logs_zuora_normalize" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:${var.region}:${var.account_id}:*"]
  }
}

data "aws_iam_policy_document" "lambda_dynamodb_zuora_normalize" {
  statement {
    actions = ["dynamodb:PutItem"]
    resources = [
      aws_dynamodb_table.price.arn,
    ]
  }
}

resource "aws_iam_role" "zuora_normalize_price" {
  name               = "${local.zuora_normalize_lambda_name}-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_zuora_normalize.json
}

resource "aws_iam_role_policy" "zuora_normalize_price_logs" {
  name   = "${local.zuora_normalize_lambda_name}-logs"
  role   = aws_iam_role.zuora_normalize_price.id
  policy = data.aws_iam_policy_document.lambda_logs_zuora_normalize.json
}

resource "aws_iam_role_policy" "zuora_normalize_price_dynamodb" {
  name   = "${local.zuora_normalize_lambda_name}-dynamodb"
  role   = aws_iam_role.zuora_normalize_price.id
  policy = data.aws_iam_policy_document.lambda_dynamodb_zuora_normalize.json
}

resource "aws_lambda_function" "zuora_normalize_price" {
  function_name    = local.zuora_normalize_lambda_name
  handler          = "normalize_zuora_price.handler"
  runtime          = "python3.11"
  role             = aws_iam_role.zuora_normalize_price.arn
  filename         = data.archive_file.zuora_normalize_price.output_path
  source_code_hash = data.archive_file.zuora_normalize_price.output_base64sha256

  environment {
    variables = {
      DYNAMO_TABLE_NAME = aws_dynamodb_table.price.name
    }
  }
}
