output "ingestion_event_bus_name" {
  value = "default"
}

output "ingestion_event_bus_arn" {
  value = "arn:aws:events:${var.region}:${var.account_id}:event-bus/default"
}

output "ingestion_webhook_url" {
  value = "${aws_api_gateway_stage.ingestion_default.invoke_url}/webhooks/zuora"
}

output "ingestion_rest_api_id" {
  value = aws_api_gateway_rest_api.ingestion_rest_api.id
}

output "ingestion_webhook_url_localstack" {
  value = "http://localhost:4566/restapis/${aws_api_gateway_rest_api.ingestion_rest_api.id}/${aws_api_gateway_stage.ingestion_default.stage_name}/_user_request_/webhooks/zuora"
}
