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

variable "zuora_webhook_name" {
  type        = string
  description = "Name for Zuora webhook."
}

variable "ingestion_rest_api_name" {
  type        = string
  description = "Name for the ingestion REST API."
}
