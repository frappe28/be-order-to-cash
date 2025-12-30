include "dev" {
  path = find_in_parent_folders("terragrunt.hcl")
}

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  backend "local" {}
}
EOF
}

locals {
  global_vars = read_terragrunt_config(find_in_parent_folders("global.hcl"))
  stage_vars  = read_terragrunt_config(find_in_parent_folders("stage.hcl"))

  global = local.global_vars.locals
  stage  = local.stage_vars.locals

  module = "api_layer"
}

dependency "data_layer" {
  config_path = "../data-layer"
}

inputs = {
  project     = local.global.project
  region      = local.global.region
  env         = local.stage.env
  account_id  = "000000000000"

  create_checkout_session_name = "${local.stage.resource_name_prefix_template}-${local.module}-create_checkout_session"
  set_payment_method_name      = "${local.stage.resource_name_prefix_template}-${local.module}-set_payment_method"
  confirm_checkout_name         = "${local.stage.resource_name_prefix_template}-${local.module}-confirm_checkout"
  get_order_status_name         = "${local.stage.resource_name_prefix_template}-${local.module}-get_order_status"
  get_price_name                = "${local.stage.resource_name_prefix_template}-${local.module}-get_price"
  webapp_api_name              = "${local.stage.resource_name_prefix_template}-${local.module}-webapp_api"
  pricing_table_name            = dependency.data_layer.outputs.pricing_table_name
}
