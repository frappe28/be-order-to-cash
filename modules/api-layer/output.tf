output "rest_api_id" {
  value = aws_api_gateway_rest_api.api.id
}

output "rest_api_invoke_url" {
  value = aws_api_gateway_stage.default.invoke_url
}

output "api_webapp_url_localstack" {
  value = "http://localhost:4566/restapis/${aws_api_gateway_rest_api.api.id}/${aws_api_gateway_stage.default.stage_name}/_user_request_"
}