locals {
  ingestion_event_bus_name    = "${var.project}-${var.env}-ingestion-bus"
  ingestion_dlq_name          = "${var.project}-${var.env}-ingestion-dlq"
  zuora_webhook_lambda_name   = "${var.project}-${var.env}-zuora-webhook"
  zuora_validate_lambda_name  = "${var.project}-${var.env}-zuora-validate-price"
  zuora_normalize_lambda_name = "${var.project}-${var.env}-zuora-normalize-price"
  ingestion_http_api_name     = "${var.project}-${var.env}-ingestion-api"
}
