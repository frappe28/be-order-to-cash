locals {
  ingestion_event_bus_name = var.ingestion_event_bus_name != "" ? var.ingestion_event_bus_name : "${var.project}-${var.env}-ingestion-bus"
  pricing_table_name       = "${var.project}-${var.env}-pricing"
  normalize_lambda_name    = "${var.project}-${var.env}-normalize-zuora-price"
}
