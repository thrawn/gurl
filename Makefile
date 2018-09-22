#vim: noexpandtab filetype=make

SHELL := /bin/bash

VARS="$(REGION)-$(ENV).tfvars"
CURRENT_FOLDER=$(shell basename "$$(pwd)")
BOLD=$(shell tput bold)
RED=$(shell tput setaf 1)
GREEN=$(shell tput setaf 2)
YELLOW=$(shell tput setaf 3)
BLUE=$(shell tput setaf 4)
MAGENTA=$(shell tput setaf 5)
CYAN=$(shell tput setaf 6)
WHITE=$(shell tput setaf 7)
RESET=$(shell tput sgr0)

ENV=dev
REGION=us-west-2
AWS_PROFILE=default


LARAVEL_VERSION := 5.6.12
LARAVEL_DIRECTORY := ./app

#DOCKER_VERSION := $(shell docker -v)
#DOCKER_COMPOSE_VERSION := $(shell docker-compose -v)

COMMIT=$(shell git rev-parse HEAD)

#NGINX := $(shell docker-compose exec nginx nginx -v 2>/dev/null )
#PHP   := $(shell docker-compose exec php php -v 2>/dev/null )
#MYSQL := $(shell docker-compose exec mysql mysql --version 2>/dev/null )
#REDIS := $(shell docker-compose exec redis redis-server -v 2>/dev/null )
#ES := $(shell curl --connect-timeout 4 http://127.0.0.1:9200/_cat/health 2>/dev/null )

#SITE_UP = $(shell curl --max-time 4 -sSfI -m 2 http://localhost:8080 2>/dev/null | head -n 1)

STAMP := `date +%Y-%m-%d-%H-%M`

# california
#
KUBECTL_VERSION := 1.10.3



all:
	@echo ''
	@echo ''
	@echo '               G U R L'
	@echo ''
	@echo '        - fast n fresh laravel - '
	@echo '  local on Docker, remote on California '
	@echo ''
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
	@make -rpn | sed -n -e '/^$$/ { n ; /^[^ .#][^ ]*:/ { s/:.*$$// ; p ; } ; }' | sort -u
	@echo ''
	@echo ''
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo ''

.PHONY:info
info:
	@echo ''
	@echo "STAMP: $(STAMP)"
	@echo "COMMIT: $(COMMIT)"
	@echo "LARAVEL: $(LARAVEL_VERSION)"
	@echo "LARAVEL DIRECTORY: $(LARAVEL_DIRECTORY)"
	@echo ''
	@./bin/info.sh
	@echo ''

.PHONY:d
d:
	docker ps -a

.PHONY:ps
ps:
	docker-compose ps

.PHONY:prune
prune: ## prune containers and images
	docker container prune
	docker image prune

.PHONY:rebuild
rebuild: ## rebuild local containers
	docker-compose build --no-cache

.PHONY:up
up: ## light up application
	@echo ''
	@docker-compose up -d
	@echo ''
	@echo 'site up?'
	@sleep 10
	@curl -sSfI http://localhost:8080 2>/dev/null | head -n 1
	@echo ''

.PHONY:down
down: ## good night, application
	@echo ''
	@docker-compose down
	@echo ''

.PHONY:restart
restart: ## restart all application containers
	@echo ''
	@docker-compose restart
	@echo ''

.PHONY:new-laravel-install
new-laravel-install: backup-laravel ## brand spankin new laravel installation, composer'd, generated, ready for the juice
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
backup-laravel: ## back up laravel ./app folder before new installation ( just in case, you know, you had code up in there )
	@if [ -d "$(LARAVEL_DIRECTORY)" ]; then \
			echo "directory exists, backing up"; \
			mv "$(LARAVEL_DIRECTORY)" "$(LARAVEL_DIRECTORY)-$(STAMP)"; \
	fi

.PHONY:app-gitignore
app-gitignore: ## add a standard laravel .gitignore file to ./app/
	cp -f config/dotfiles/app_gitignore app/.gitignore

.PHONY:app-env
app-env: ## add the laravel application .env file
	cp -f config/dotfiles/app_env app/.env

.PHONY:composer-update
composer-update: ## update the thing
	time docker run --rm -v $(PWD)/app:/app composer update

.PHONY:composer-install
composer-install: ## install the thing
	time docker run --rm -v $(PWD)/app:/app composer -q install

.PHONY:yarn-install
yarn-install: ## yarn install in app directory
	time docker run --rm -v $(PWD)/app:/app node:alpine yarn install

.PHONY:npm-install
npm-install: ## npm install in app directory
	time docker run --user 501 --rm -v $(PWD)/app:/app node:alpine npm install

# california
#



set-env:
	@if [ -z $(ENV) ]; then \
		echo "$(BOLD)$(RED)ENV was not set$(RESET)"; \
		ERROR=1; \
	fi
	#####
	@if [ -z $(REGION) ]; then \
		echo "$(BOLD)$(RED)REGION was not set$(RESET)"; \
		ERROR=1; \
	fi
	#####
	@if [ -z $(AWS_PROFILE) ]; then \
		echo "$(BOLD)$(RED)AWS_PROFILE was not set.$(RESET)"; \
		ERROR=1; \
	fi
	#####
	@if [ ! -z $${ERROR} ] && [ $${ERROR} -eq 1 ]; then \
		echo "$(BOLD)Example usage: \`AWS_PROFILE=whatever ENV=demo REGION=us-east-2 make plan\`$(RESET)"; \
		exit 1; \
	fi
	#####
	@if [ ! -f "$(VARS)" ]; then \
		echo "$(BOLD)$(RED)Could not find variables file: $(VARS)$(RESET)"; \
		exit 1; \
	fi

.PHONY:check-aws-account
check-aws-account: ## make sure local aws account number matches remote aws account number
	./bin/account-check.sh

.PHONY:get-kubectl ## download iam-auth kubectl
get-kubectl:
	@echo ''
	@echo "fetching version $(KUBECTL_VERSION) kubectl"
	@[ ./california/kubectl ] && rm -f ./california/kubectl 2>/dev/null
	@[ ./california/kubectl.sha256 ] && rm -f ./california/kubectl.sha256 2>/dev/null
	@curl -s -o ./california/kubectl https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-07-26/bin/darwin/amd64/kubectl
	@chmod +x ./california/kubectl
	@echo 'sha-256 check'
	@curl -s -o ./california/kubectl.sha256 https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-07-26/bin/darwin/amd64/kubectl.sha256
	@openssl sha -sha256 ./california/kubectl
	@echo 'kubectl.sha256 file'
	@cat ./california/kubectl.sha256
	@echo 'complete'
	@echo ''

.PHONY:get-aws-iam-authenticator
get-aws-iam-authenticator: ## download aws-iam-authenticator
	@echo ''
	@echo "fetching aws-iam-authenticator"
	@[ ./california/aws-iam-authenticator ] && rm -f ./california/aws-iam-authenticator 2>/dev/null
	@[ ./california/aws-iam-authenticator.sha256 ] && rm -f ./california/aws-iam-authenticator.sha256 2>/dev/null
	@curl -s -o ./california/aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-07-26/bin/darwin/amd64/aws-iam-authenticator
	@chmod +x ./california/aws-iam-authenticator
	@echo 'sha-256 check'
	@curl -s -o ./california/aws-iam-authenticator.sha256 https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-07-26/bin/darwin/amd64/aws-iam-authenticator.sha256
	@openssl sha -sha256 ./california/aws-iam-authenticator
	@echo 'aws-iam-authenticator.sha256 file'
	@cat ./california/aws-iam-authenticator.sha256
	@echo 'complete'
	@echo ''


.PHONY:aws
aws: ## show aws credentials
	cat credentials/aws-credentials.json | jq -r '.'

.PHONY: terra
terra:terraform-init terraform-plan terraform-show
	

.PHONY:terraform-init
terraform-init:
	cd ./california/; \
	pwd; \
	terraform init

.PHONY:terraform-clean
terraform-clean:
	rm -rf ./california/.terraform

.PHONY:terraform-plan
terraform-plan:
	cd ./california/; \
	terraform plan

.PHONY:terraform-show
terraform-show:
	cd ./california/; \
	terraform show

.PHONY:terraform-apply
terraform-apply:
	cd ./california; \
	terraform apply
