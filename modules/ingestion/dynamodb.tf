resource "aws_dynamodb_table" "price" {
  name         = "${var.env}-${var.project}-${var.price_table_name}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}