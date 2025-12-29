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

variable "create_checkout_session_lambda_name" {
  type        = string
  description = "Lambda function name for create checkout session."
}

variable "set_payment_method_lambda_name" {
  type        = string
  description = "Lambda function name for set payment method."
}

variable "confirm_checkout_lambda_name" {
  type        = string
  description = "Lambda function name for confirm checkout."
}

variable "get_order_status_lambda_name" {
  type        = string
  description = "Lambda function name for get order status."
}
