data "archive_file" "get_order_status" {
  type        = "zip"
  source_file = "${path.module}/lambda-src/get_order_status.py"
  output_path = "${path.module}/lambda-src/get_order_status.zip"
}

data "aws_iam_policy_document" "lambda_assume_role_get_order_status" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_logs_get_order_status" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:${var.region}:${var.account_id}:*"]
  }
}

resource "aws_iam_role" "get_order_status" {
  name               = "${var.project}-${var.env}-api-layer-get-order-status-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_get_order_status.json
}

resource "aws_iam_role_policy" "get_order_status_logs" {
  name   = "${var.project}-${var.env}-api-layer-get-order-status-logs"
  role   = aws_iam_role.get_order_status.id
  policy = data.aws_iam_policy_document.lambda_logs_get_order_status.json
}

resource "aws_lambda_function" "get_order_status" {
  function_name    = var.get_order_status_name
  handler          = "get_order_status.handler"
  runtime          = "python3.12"
  role             = aws_iam_role.get_order_status.arn
  filename         = data.archive_file.get_order_status.output_path
  source_code_hash = data.archive_file.get_order_status.output_base64sha256
}

resource "aws_lambda_permission" "get_order_status_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway-get-order-status"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_order_status.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}
