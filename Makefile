
SHELL := /bin/bash

LARAVEL_VERSION := 5.6.12
LARAVEL_DIRECTORY := ./app

DOCKER_VERSION := $(shell docker -v)
DOCKER_COMPOSE_VERSION := $(shell docker-compose -v)

COMMIT=$(shell git rev-parse HEAD)

NGINX := $(shell docker-compose exec nginx nginx -v 2>/dev/null )
PHP   := $(shell docker-compose exec php php -v 2>/dev/null )
MYSQL := $(shell docker-compose exec mysql mysql --version 2>/dev/null )
REDIS := $(shell docker-compose exec redis redis-server -v 2>/dev/null )
ES := $(shell curl http://127.0.0.1:9200/_cat/health 2>/dev/null )

SITE_UP = $(shell curl -sSfI -m 2 http://localhost:8080 2>/dev/null | head -n 1)

STAMP := `date +%Y-%m-%d-%H-%M`



all:
	@echo ''
	@echo ''
	@echo '               G U R L'
	@echo ''
	@echo '        - fast n fresh laravel - '
	@echo '  local on Docker, remote on California-K '
	@echo ''
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
	@echo 'commands'
	@echo ''
	@echo 'make up'
	@echo 'make down'
	@echo 'make new-laravel-install'
	@echo 'make composer-update'
	@echo 'make composer-install'
	@echo 'make docker'
	@echo 'make docker-prune'
	@echo ''
	@echo ''

.PHONY:d
d:
	docker ps -a

.PHONY:ps
ps:
	docker-compose ps

.PHONY:prune
prune:
	docker container prune
	docker image prune

.PHONY:rebuild
rebuild:
	docker-compose build --no-cache

.PHONY:up
up:
	@echo ''
	@docker-compose up -d
	@echo ''
	@echo 'site up?'
	@sleep 10
	@curl -sSfI http://localhost:8080 2>/dev/null | head -n 1
	@echo ''

.PHONY:down
down:
	@echo ''
	@docker-compose down
	@echo ''

.PHONY:restart
restart:
	@echo ''
	@docker-compose restart
	@echo ''

.PHONY:new-laravel-install
new-laravel-install: backup-laravel
	$(MAKE) down
	@echo ''
	@echo "installing laravel $(LARAVEL_VERSION) to ./app"
	@echo ''
	@echo "downloading laravel $(LARAVEL_VERSION)"
	@echo ''
	@curl -s -L https://github.com/laravel/laravel/archive/v$(LARAVEL_VERSION).tar.gz | tar xz
	@echo "moving $(LARAVEL_VERSION) to ./app"
	@mv ./laravel-$(LARAVEL_VERSION) ./app
	@echo ''
	@echo "setting permissions to 777 on ./app/storage and ./app/bootstrap/cache"
	@chmod -R 777 ./app/storage && chmod -R 777 ./app/bootstrap/cache
	@echo ''
	@echo "composer install"
	$(MAKE) composer-install
	@echo ''
	$(MAKE) app-gitignore
	$(MAKE) app-env
	@echo ''
	$(MAKE) up
	@sleep 30
	@echo ''
	@#echo "create laravel application key"
	@#docker-compose exec app php artisan key:generate
	@echo ''
	@docker-compose exec nginx nginx -v
	@docker-compose exec php php -v
	@echo ''
	@echo 'complete'
	@echo ''

.PHONY:backup-laravel
backup-laravel:
	@if [ -d "$(LARAVEL_DIRECTORY)" ]; then \
			echo "directory exists, backing up"; \
			mv "$(LARAVEL_DIRECTORY)" "$(LARAVEL_DIRECTORY)-$(STAMP)"; \
	fi

.PHONY:app-gitignore
app-gitignore:
	cp -f config/dotfiles/app_gitignore app/.gitignore

.PHONY:app-env
app-env:
	cp -f config/dotfiles/app_env app/.env

.PHONY:composer-update
composer-update:
	time docker run --rm -v $(PWD)/app:/app composer update

.PHONY:composer-install
composer-install:
	time docker run --rm -v $(PWD)/app:/app composer -q install
