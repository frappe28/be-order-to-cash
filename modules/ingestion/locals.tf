locals {
  ingestion_dlq_name         = "${var.project}-${var.env}-ingestion-dlq"
  zuora_webhook_lambda_name  = "${var.project}-${var.env}-zuora-webhook"
  zuora_validate_lambda_name = "${var.project}-${var.env}-zuora-validate-price"
  ingestion_http_api_name    = "${var.project}-${var.env}-ingestion-api"
}
