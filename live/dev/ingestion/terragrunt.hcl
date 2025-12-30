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
}

inputs = {
  project    = local.global.project
  region     = local.global.region
  env        = local.stage.env
  account_id = "000000000000"

  price_table_name = "price"
}