locals {
  global_vars = read_terragrunt_config(find_in_parent_folders("global.hcl"))
  stage_vars  = read_terragrunt_config("${path_relative_from_include()}/stage.hcl")

  global = local.global_vars.locals
  stage  = local.stage_vars.locals
}

remote_state {
  backend = "local"
  config = {
    path = "${get_terragrunt_dir()}/${path_relative_to_include()}.tfstate"
  }
}

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//${split("/", path_relative_to_include())[0]}"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
    provider "aws" {
      region                      = "${local.global.region}"
      access_key                  = "test"
      secret_key                  = "test"
      skip_credentials_validation = true
      skip_metadata_api_check     = true
      skip_requesting_account_id  = true
      s3_use_path_style           = true

      endpoints {
        apigateway    = "http://localhost:4566"
        apigatewayv2  = "http://localhost:4566"
        dynamodb      = "http://localhost:4566"
        events        = "http://localhost:4566"
        iam           = "http://localhost:4566"
        lambda        = "http://localhost:4566"
        logs          = "http://localhost:4566"
        sqs           = "http://localhost:4566"
        s3            = "http://localhost:4566"
        stepfunctions = "http://localhost:4566"
      }

      default_tags {
        tags = {
          Project         = "${local.global.tags.project}"
          "Creation Date" = "${formatdate("YYYY-MM-DD", timestamp())}"
          Environment     = "${local.stage.env}"
        }
      }

      ignore_tags {
        keys = ["Creation Date"]
      }
    }
  EOF
}

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite"
  contents  = <<EOF
  terraform {
    backend "s3" {}
  }
  EOF
}
