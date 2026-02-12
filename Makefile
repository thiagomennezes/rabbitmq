deploy-production:
	docker compose -f docker-compose-production.yml up -d

deploy-test:
	docker compose -f docker-compose-test.yml up -d

deploy-develop:
	docker compose -f docker-compose-develop.yml up -d
