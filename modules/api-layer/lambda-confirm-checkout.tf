data "archive_file" "confirm_checkout" {
  type        = "zip"
  source_file = "${path.module}/lambda-src/confirm_checkout.py"
  output_path = "${path.module}/lambda-src/confirm_checkout.zip"
}

data "aws_iam_policy_document" "lambda_assume_role_confirm_checkout" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_logs_confirm_checkout" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:${var.region}:${var.account_id}:*"]
  }
}

resource "aws_iam_role" "confirm_checkout" {
  name               = "${var.project}-${var.env}-api-layer-confirm-checkout-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_confirm_checkout.json
}

resource "aws_iam_role_policy" "confirm_checkout_logs" {
  name   = "${var.project}-${var.env}-api-layer-confirm-checkout-logs"
  role   = aws_iam_role.confirm_checkout.id
  policy = data.aws_iam_policy_document.lambda_logs_confirm_checkout.json
}

resource "aws_lambda_function" "confirm_checkout" {
  function_name    = var.confirm_checkout_name
  handler          = "confirm_checkout.handler"
  runtime          = "python3.12"
  role             = aws_iam_role.confirm_checkout.arn
  filename         = data.archive_file.confirm_checkout.output_path
  source_code_hash = data.archive_file.confirm_checkout.output_base64sha256
}

resource "aws_lambda_permission" "confirm_checkout_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway-confirm-checkout"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.confirm_checkout.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}
