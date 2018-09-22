#!/bin/bash

DOCKER_VERSION=$(docker -v)
DOCKER_COMPOSE_VERSION=$(docker-compose -v)

COMMIT=$(git rev-parse HEAD)

NGINX_VERSION=$(docker-compose exec nginx nginx -v 2>/dev/null )
PHP_VERSION=$(docker-compose exec php php -v 2>/dev/null )
MYSQL_VERSION=$(docker-compose exec mysql mysql --version 2>/dev/null )
REDIS_VERSION=$(docker-compose exec redis redis-server -v 2>/dev/null )
ES=$(curl --connect-timeout 4 http://127.0.0.1:9200/_cat/health 2>/dev/null )
SITE_UP=$(curl --max-time 4 -sSfI -m 2 http://localhost:8080 2>/dev/null | head -n 1)


echo "COMMIT: $COMMIT"
echo "DOCKER: $DOCKER_VERSION"
echo "DOCKER COMPOSE: $DOCKER_COMPOSE_VERSION"
echo ''
echo "NGINX: $NGINX_VERSION"
echo "PHP: $PHP_VERSION"
echo "MYSQL: $MYSQL_VERSION"
echo "REDIS: $REDIS_VERSION"
echo "ELASTICSEARCH: $ES"
echo ''
[ "$SITE_UP" ] && echo "Site Up? yup!  $SITE_UP" || echo "Site up? nope"
echo ''
