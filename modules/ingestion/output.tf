output "ingestion_event_bus_name" {
  value = aws_cloudwatch_event_bus.ingestion.name
}

output "ingestion_event_bus_arn" {
  value = aws_cloudwatch_event_bus.ingestion.arn
}

output "ingestion_dlq_url" {
  value = aws_sqs_queue.ingestion_dlq.url
}

output "ingestion_webhook_url" {
  value = "${aws_apigatewayv2_api.ingestion_http_api.api_endpoint}/${aws_apigatewayv2_stage.ingestion_default.name}/webhooks/zuora"
}
