data "archive_file" "create_checkout_session" {
  type        = "zip"
  source_file = "${path.module}/lambda-src/create_checkout_session.py"
  output_path = "${path.module}/lambda-src/create_checkout_session.zip"
}

data "aws_iam_policy_document" "lambda_assume_role_create_checkout_session" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_logs_create_checkout_session" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:${var.region}:${var.account_id}:*"]
  }
}

resource "aws_iam_role" "create_checkout_session" {
  name               = "${var.project}-${var.env}-api-layer-create-checkout-session-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_create_checkout_session.json
}

resource "aws_iam_role_policy" "create_checkout_session_logs" {
  name   = "${var.project}-${var.env}-api-layer-create-checkout-session-logs"
  role   = aws_iam_role.create_checkout_session.id
  policy = data.aws_iam_policy_document.lambda_logs_create_checkout_session.json
}

resource "aws_lambda_function" "create_checkout_session" {
  function_name    = var.create_checkout_session_name
  handler          = "create_checkout_session.handler"
  runtime          = "python3.12"
  role             = aws_iam_role.create_checkout_session.arn
  filename         = data.archive_file.create_checkout_session.output_path
  source_code_hash = data.archive_file.create_checkout_session.output_base64sha256
}

resource "aws_lambda_permission" "create_checkout_session_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway-create-checkout-session"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_checkout_session.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}
