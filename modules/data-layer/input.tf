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

variable "ingestion_event_bus_name" {
  type        = string
  description = "EventBridge bus name for ingestion events."
  default     = ""
}
