locals {
  pricing_table_name       = "${var.env}-${var.project}-${var.price_table_name}"
  normalize_lambda_name    = "${var.project}-${var.env}-normalize-zuora-price"
}
