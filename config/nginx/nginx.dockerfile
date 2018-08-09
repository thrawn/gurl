FROM nginx:1.15-alpine

ADD vhost.conf /etc/nginx/conf.d/default.conf
