


LARAVEL_VERSION := 5.4.30
LARAVEL_DIRECTORY := ./app

DOCKER_VERSION := $(shell docker -v)
DOCKER_COMPOSE_VERSION := $(shell docker-compose -v)

COMMIT=$(shell git rev-parse HEAD)

NGINX := $(shell docker-compose exec web nginx -v 2>/dev/null )
PHP   := $(shell docker-compose exec app php -v 2>/dev/null )
MYSQL := $(shell docker-compose exec mysql mysql --version 2>/dev/null )
REDIS := $(shell docker-compose exec redis redis-server -v 2>/dev/null )
ES := $(shell curl http://127.0.0.1:9200/_cat/health 2>/dev/null )

SITE_UP = $(shell curl -sSfI http://localhost:8080 2>/dev/null | head -n 1)

STAMP := `date +%Y-%m-%d-%H-%M`



all:
	@echo ''
	@echo "COMMIT: $(COMMIT)"
	@echo "LARAVEL: $(LARAVEL_VERSION)"
	@echo "LARAVEL DIRECTORY: $(LARAVEL_DIRECTORY)"
	@echo "DOCKER: $(DOCKER_VERSION)"
	@echo "DOCKER COMPOSE: $(DOCKER_COMPOSE_VERSION)"
	@echo ''
	@echo "NGINX: $(NGINX)"
	@echo "PHP: $(PHP)"
	@echo "MYSQL: $(MYSQL)"
	@echo "REDIS: $(REDIS)"
	@echo "ELASTICSEARCH: $(ES)"
	@echo ''
	@echo "Site Up? $(SITE_UP)"
	@echo ''
	@echo "STAMP: $(STAMP)"
	@echo ''

up:
	@echo ''
	@docker-compose up -d
	@echo ''
	@echo 'site up?'
	@sleep 3
	@curl -sSfI http://localhost:8080 | head -n 1
	@echo ''

down:
	@echo ''
	@docker-compose down
	@echo ''

new-laravel-install: backup-laravel
	@echo ''
	@echo "installing laravel $(LARAVEL_VERSION) to ./app"
	@echo ''
	@echo "downloading laravel $(LARAVEL_VERSION)"
	@curl -s -L https://github.com/laravel/laravel/archive/v$(LARAVEL_VERSION).tar.gz | tar xz
	@echo "moving $(LARAVEL_VERSION) to ./app"
	@mv ./laravel-$(LARAVEL_VERSION) ./app
	@echo "setting permissions to 777 on ./app/storage and ./app/bootstrap/cache"
	@chmod -R 777 ./app/storage && chmod -R 777 ./app/bootstrap/cache
	@echo "composer install"
	$(MAKE) composer-install
	@echo "create ./app/.env file"
	@mv ./app/.env.example ./app/.env
	@echo "docker-compose up -d"
	@docker-compose up -d
	@echo "create laravel application key"
	@docker-compose exec app php artisan key:generate
	@echo "optimize laravel"
	@docker-compose exec app php artisan optimize
	@echo ''
	@docker-compose exec web nginx -v
	@docker-compose exec app php -v
	@echo ''
	@echo 'complete'
	@echo ''

	

backup-laravel:
	@if [ -d "$(LARAVEL_DIRECTORY)" ]; then \
			echo "directory exists, backing up"; \
			mv "$(LARAVEL_DIRECTORY)" "$(LARAVEL_DIRECTORY)-$(STAMP)"; \
	fi

composer-update:
	docker run --rm -v $(PWD)/app:/app composer/composer update

composer-install:
	docker run --rm -v $(PWD)/app:/app composer/composer install
