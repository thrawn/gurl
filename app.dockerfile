FROM php:7.1-fpm

#RUN apt-get update && apt-get install -y libmcrypt-dev mcrypt php7-mcrypt \
#    mysql-client libmagickwand-dev --no-install-recommends \
#    && pecl install imagick \
#    && docker-php-ext-enable imagick \
#    && docker-php-ext-install mcrypt pdo_mysql

RUN apt-get update && apt-get install -y \
        libzip-dev \
        libicu-dev \
        libpq-dev \
        libbz2-dev \
        mc \
        wget \
        libxml2 \
        libxslt-dev \
    && docker-php-ext-install xsl \
    && docker-php-ext-install iconv \
    && docker-php-ext-install zip \
    && docker-php-ext-install bz2 \
    && docker-php-ext-install mbstring \
    && docker-php-ext-install intl \
    && docker-php-ext-install pgsql pdo pdo_pgsql \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install bcmath \
    && docker-php-ext-install opcache \
    && docker-php-ext-enable opcache \
    && apt-get install -y -q --no-install-recommends \
       ssmtp

# Install mcrypt
RUN apt-get install -y libmcrypt-dev
RUN docker-php-ext-install mcrypt

# Install GD
RUN apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng12-dev \
    && docker-php-ext-configure gd \
          --enable-gd-native-ttf \
          --with-freetype-dir=/usr/include/freetype2 \
          --with-png-dir=/usr/include \
          --with-jpeg-dir=/usr/include \
    && docker-php-ext-install gd \
    && docker-php-ext-enable gd

# Install Imagick
RUN apt-get install -y \
       libmagickwand-dev \
    && pecl install imagick \
    && docker-php-ext-enable imagick
