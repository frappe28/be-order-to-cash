locals {
  region              = "eu-west-1"
  project             = "order-to-cash"
  owner               = "fdeperte"
  iam_role_arn_prefix = "arn:aws:iam::000000000000:role/" # Static account ID for LocalStack

  tags = {
    project            = "order-to-cash"
  }
}