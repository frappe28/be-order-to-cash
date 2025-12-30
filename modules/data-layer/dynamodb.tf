resource "aws_dynamodb_table" "pricing" {
  name         = var.price_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "price_id"

  attribute {
    name = "price_id"
    type = "S"
  }
}
