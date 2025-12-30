variable "project" {
  type        = string
  description = "Project name."
}

variable "region" {
  type        = string
  description = "AWS Region"
}

variable "env" {
  type        = string
  description = "Environment"
}

variable "account_id" {
  type        = string
  description = "Account ID"
}

variable "validate_zuora_price_name" {
  type        = string
  description = "Name for validating Zuora price data."
}

variable "zuora_webhook_name" {
  type        = string
  description = "Name for Zuora webhook."
}

variable "ingestion_rest_api_name" {
  type        = string
  description = "Name for the ingestion REST API."
}

variable "ingestion_dlq_name" {
  type        = string
  description = "Name for the ingestion dead-letter queue."
}

variable "zuora_webhook_event_rule_name" {
  type        = string
  description = "Name for the Zuora webhook EventBridge rule."
}