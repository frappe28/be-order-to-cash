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

variable "price_table_name" {
  type        = string
  description = "DynamoDB Price Table Name"
}
