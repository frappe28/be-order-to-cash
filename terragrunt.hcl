locals {
  project_name     = "be-order-to-cash"
  aws_region       = "eu-west-1"
  state_bucket     = "be-order-to-cash-terraform-state"
  state_lock_table = "be-order-to-cash-terraform-locks"
}

remote_state {
  backend = "s3"
  config = {
    bucket         = local.state_bucket
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    encrypt        = true
    dynamodb_table = local.state_lock_table
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF2
provider "aws" {
  region = local.aws_region
}
EOF2
}

inputs = {
  project_name = local.project_name
}
