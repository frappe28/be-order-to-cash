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

variable "create_checkout_session_name" {
  type        = string
  description = "Lambda function name for creating checkout sessions."
}

variable "set_payment_method_name" {
  type        = string
  description = "Lambda function name for setting payment method."
}

variable "confirm_checkout_name" {
  type        = string
  description = "Lambda function name for confirming checkout."
}

variable "get_order_status_name" {
  type        = string
  description = "Lambda function name for getting order status."
}

variable "get_price_name" {
  type        = string
  description = "Lambda function name for reading prices."
}

variable "pricing_table_name" {
  type        = string
  description = "DynamoDB pricing table name."
}

variable "webapp_api_name" {
  type        = string
  description = "Name of the API Gateway REST API."
}
