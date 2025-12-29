locals {
  region              = "eu-west-1"
  project             = "order-to-cash"
  owner               = "fdeperte"
  iam_role_arn_prefix = "arn:aws:iam::${get_aws_account_id()}:role/"

  tags = {
    project            = "order-to-cash"
  }
}