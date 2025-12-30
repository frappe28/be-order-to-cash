# be-order-to-cash

POC backend to ingest price updates from a Zuora-style webhook, validate and normalize the payload, and persist it in DynamoDB via EventBridge.

## What it does
- REST API endpoint: POST `/webhooks/zuora`
- Lambda `zuora_webhook` publishes the raw payload to EventBridge
- Lambda `zuora_validate_price` validates required fields
- Lambda `zuora_normalize_price` normalizes and writes to DynamoDB

Normalized fields stored in DynamoDB:
- `price_id`
- `sku`
- `amount`
- `currency`
- `market` (derived from `market_key`/`price_list`/`region`)

## Local setup (LocalStack)
Requirements:
- Docker
- Terraform + Terragrunt
- AWS CLI

Start LocalStack:
```bash
make -f infra/localstack/Makefile localstack-up
```

Apply the ingestion module:
```bash
cd live/dev/ingestion
terragrunt apply
```

Get the local webhook endpoint:
```bash
terragrunt output -raw ingestion_webhook_url_localstack
```

## Demo the ingestion flow
Example payload (intentionally "dirty"):
```json
{
  "price_id": "  p-001 ",
  "sku": "  book-abc  ",
  "amount": "12.90",
  "currency": " eur ",
  "market_key": "EU-books-2024",
  "extra_field": "da_scartare"
}
```

Call the endpoint from Postman or curl (make sure it is a POST):
```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"price_id":"  p-001 ","sku":"  book-abc  ","amount":"12.90","currency":" eur ","market_key":"EU-books-2024","extra_field":"da_scartare"}' \
  "$(terragrunt output -raw ingestion_webhook_url_localstack)"
```

Expected response:
```json
{"message":"Event accepted"}
```

Verify DynamoDB:
```bash
AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=eu-west-1 \
  aws --endpoint-url=http://localhost:4566 dynamodb scan \
  --table-name dev-order-to-cash-price
```

You should see normalized values:
- `sku` and `currency` uppercase
- `amount` stored as a number
- `market` derived from the input key

## Notes
- LocalStack must include `apigateway` in `SERVICES`.
- If you change API resources, re-run `terragrunt apply` to redeploy API Gateway.
