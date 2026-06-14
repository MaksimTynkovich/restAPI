include .env
export

export PROJECT_ROOT=$(shell pwd)

env-up:
	@docker compose up -d restapi-postgres

env-down:
	@docker compose down restapi-postgres

env-port-forward:
	@docker compose up -d port-forwarder

env-port-close:
	@docker compose down port-forwarder

env-cleanup:
	@read -p "Очистить все volume файлы окружения? Ведёт к утери данных [y/N]: " ans; \
	if [ "$$ans" = "y" ]; then \
	  docker compose down restapi-postgres && \
	  rm -rf out/pgdata && \
	  echo "Файлы окружения удалены"; \
	else \
	  echo "Операция отменена"; \
	fi

migrate-create:
	@if [ -z "$(seq)" ]; then \
  		echo "Укажите версию миграции. Пример: make migrate-create seq=version"; \
  		exit 1; \
  	fi; \
	docker compose run --rm restapi-postgres-migrate \
		create \
		-ext sql \
		-dir /migrations \
		-seq "$(seq)"

migrate-up:
	@make migrate-action action=up

migrate-down:
	@make migrate-action action=down

migrate-action:
	@if [ -z "$(action)" ]; then \
  		echo "Отсутствует параметр action. Пример: make migrate-action action=up"; \
  		exit 1; \
  	fi; \
	docker compose run --rm restapi-postgres-migrate \
    	-path /migrations \
    	-database postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@restapi-postgres:5432/${POSTGRES_DB}?sslmode=disable \
   		"$(action)"