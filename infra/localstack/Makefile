localstack-up:
	cd infra/localstack && docker compose up -d

localstack-down:
	cd infra/localstack && docker compose down

localstack-logs:
	docker logs -f localstack

localstack-reset:
	cd infra/localstack && docker compose down -v && rm -rf data
