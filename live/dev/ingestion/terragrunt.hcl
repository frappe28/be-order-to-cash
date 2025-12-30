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

  module = "ingestion"
}

inputs = {
  project                       = local.global.project
  region                        = local.global.region
  env                           = local.stage.env

  account_id  = "000000000000"
  
  zuora_webhook_name      = "${local.stage.resource_name_prefix_template}-${local.module}-zuora_webhook"
  ingestion_rest_api_name = "${local.stage.resource_name_prefix_template}-${local.module}-webhook_api"

}
