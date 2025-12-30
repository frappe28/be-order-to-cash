data "archive_file" "get_price" {
  type        = "zip"
  source_file = "${path.module}/lambda-src/get_price.py"
  output_path = "${path.module}/lambda-src/get_price.zip"
}

data "aws_iam_policy_document" "lambda_assume_role_get_price" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_logs_get_price" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:${var.region}:${var.account_id}:*"]
  }
}

data "aws_iam_policy_document" "lambda_dynamodb_get_price" {
  statement {
    actions   = ["dynamodb:GetItem"]
    resources = ["arn:aws:dynamodb:${var.region}:${var.account_id}:table/${var.pricing_table_name}"]
  }
}

resource "aws_iam_role" "get_price" {
  name               = "${var.project}-${var.env}-api-layer-get-price-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_get_price.json
}

resource "aws_iam_role_policy" "get_price_logs" {
  name   = "${var.project}-${var.env}-api-layer-get-price-logs"
  role   = aws_iam_role.get_price.id
  policy = data.aws_iam_policy_document.lambda_logs_get_price.json
}

resource "aws_iam_role_policy" "get_price_dynamodb" {
  name   = "${var.project}-${var.env}-api-layer-get-price-dynamodb"
  role   = aws_iam_role.get_price.id
  policy = data.aws_iam_policy_document.lambda_dynamodb_get_price.json
}

resource "aws_lambda_function" "get_price" {
  function_name    = var.get_price_name
  handler          = "get_price.handler"
  runtime          = "python3.12"
  role             = aws_iam_role.get_price.arn
  filename         = data.archive_file.get_price.output_path
  source_code_hash = data.archive_file.get_price.output_base64sha256

  environment {
    variables = {
      PRICING_TABLE_NAME = var.pricing_table_name
    }
  }
}

resource "aws_lambda_permission" "get_price_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway-get-price"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_price.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}
