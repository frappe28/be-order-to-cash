data "archive_file" "set_payment_method" {
  type        = "zip"
  source_file = "${path.module}/lambda-src/set_payment_method.py"
  output_path = "${path.module}/lambda-src/set_payment_method.zip"
}

data "aws_iam_policy_document" "lambda_assume_role_set_payment_method" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_logs_set_payment_method" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:${var.region}:${var.account_id}:*"]
  }
}

resource "aws_iam_role" "set_payment_method" {
  name               = "${var.project}-${var.env}-api-layer-set-payment-method-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_set_payment_method.json
}

resource "aws_iam_role_policy" "set_payment_method_logs" {
  name   = "${var.project}-${var.env}-api-layer-set-payment-method-logs"
  role   = aws_iam_role.set_payment_method.id
  policy = data.aws_iam_policy_document.lambda_logs_set_payment_method.json
}

resource "aws_lambda_function" "set_payment_method" {
  function_name    = var.set_payment_method_name
  handler          = "set_payment_method.handler"
  runtime          = "python3.12"
  role             = aws_iam_role.set_payment_method.arn
  filename         = data.archive_file.set_payment_method.output_path
  source_code_hash = data.archive_file.set_payment_method.output_base64sha256
}

resource "aws_lambda_permission" "set_payment_method_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway-set-payment-method"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.set_payment_method.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}
