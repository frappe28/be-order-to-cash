output "pricing_table_name" {
  value = aws_dynamodb_table.pricing.name
}

output "pricing_table_arn" {
  value = aws_dynamodb_table.pricing.arn
}
