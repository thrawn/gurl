FROM php:7.2-fpm

#RUN apt-get update && apt-get install -y libmcrypt-dev mcrypt php7-mcrypt \
#    mysql-client libmagickwand-dev --no-install-recommends \
#    && pecl install imagick \
#    && docker-php-ext-enable imagick \
#    && docker-php-ext-install mcrypt pdo_mysql
#

# Locales
RUN apt-get update \
    && apt-get install -y locales

RUN dpkg-reconfigure locales \
    && locale-gen C.UTF-8 \
    && /usr/sbin/update-locale LANG=C.UTF-8

RUN echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen \
    && locale-gen

ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# Common
#     && apt-get install -y -q --no-install-recommends \
#       ssmtp
#
RUN apt-get update \
    && apt-get install -y -q --no-install-recommends \
    openssl \
    git \
    ssmtp \
    gnupg2

# intl
RUN apt-get update \
    && apt-get install -y -q --no-install-recommends libicu-dev \
    && docker-php-ext-configure intl \
    && docker-php-ext-install -j$(nproc) intl

# xml
RUN apt-get update \
    && apt-get install -y -q --no-install-recommends \
    libxml2-dev \
    libxslt-dev \
    && docker-php-ext-install -j$(nproc) \
        dom \
        xmlrpc \
        xsl

# images
RUN apt-get update \
    && apt-get install -y -q --no-install-recommends \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libgd-dev \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) \
        gd \
        exif

# strings
RUN docker-php-ext-install -j$(nproc) \
    gettext \
    mbstring

# math
RUN apt-get update \
    && apt-get install -y -q --no-install-recommends libgmp-dev \
    && ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h \
    && docker-php-ext-install -j$(nproc) \
        gmp \
        bcmath

# compression
RUN apt-get update \
    && apt-get install -y -q --no-install-recommends \
    libbz2-dev \
    zlib1g-dev \
    && docker-php-ext-install -j$(nproc) \
        zip \
        bz2

RUN apt-get update && apt-get install -y -q --no-install-recommends libc-client-dev libkrb5-dev
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install imap

# ftp
RUN apt-get update \
    && apt-get install -y -q --no-install-recommends \
    libssl-dev \
    && docker-php-ext-install -j$(nproc) \
    ftp

# ssh2
RUN apt-get update \
    && apt-get install -y -q --no-install-recommends \
    libssh2-1-dev

# memcached
RUN apt-get update \
    && apt-get install -y -q --no-install-recommends \
    libmemcached-dev \
    libmemcached11


# others
RUN docker-php-ext-install -j$(nproc) \
    soap \
    sockets \
    calendar \
    pcntl \
    shmop \
    sysvmsg \
    sysvsem \
    sysvshm \
    wddx

# PECL
RUN pecl install ssh2-1.1.2 \
    && pecl install redis-4.0.2 \
    && pecl install apcu-5.1.11 \
    && pecl install memcached-3.0.4 \
    && pecl install msgpack-2.0.2 \
    && pecl install igbinary-2.0.7 \
    && docker-php-ext-enable redis apcu memcached msgpack igbinary

RUN apt-get update && apt-get install -y -q --no-install-recommends \
        libzip-dev \
        libicu-dev \
        libpq-dev \
        libbz2-dev \
        libmemcached-dev \
        libmemcachedutil2 \
        wget \
        libxml2 \
        libxslt-dev \
        libssl-dev \
    && docker-php-ext-install xsl \
    && docker-php-ext-install iconv \
    && docker-php-ext-install zip \
    && docker-php-ext-install bz2 \
    && docker-php-ext-install mbstring \
    && docker-php-ext-install intl \
    && docker-php-ext-install pgsql pdo pdo_pgsql \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install mysqli \
    && docker-php-ext-install bcmath \
    && docker-php-ext-install opcache \
    && docker-php-ext-enable opcache \
    && docker-php-ext-install exif
    #&& docker-php-ext-install calendar \
    #&& docker-php-ext-install gettext \
    #&& docker-php-ext-install ftp \
    #&& docker-php-ext-install imap \
    #&& pecl install memcached redis msgpack \
    #&& docker-php-ext-enable memcached.so redis.so msgpack.so \

# Install mcrypt
# laravel no longer needs mcrypt
RUN apt-get install -y gcc make autoconf libc-dev pkg-config libmcrypt-dev #php7-mcrypt
RUN pecl install mcrypt-1.0.1 && docker-php-ext-enable mcrypt

# Install GD
RUN apt-get install -y -q --no-install-recommends \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
    && docker-php-ext-configure gd \
          --enable-gd-native-ttf \
          --with-freetype-dir=/usr/include/freetype2 \
          --with-png-dir=/usr/include \
          --with-jpeg-dir=/usr/include \
    && docker-php-ext-install gd \
    && docker-php-ext-enable gd

# Install Imagick
RUN apt-get install -y -q --no-install-recommends \
       libmagickwand-dev \
    && pecl install imagick \
    && docker-php-ext-enable imagick

# GEOS
RUN wget http://download.osgeo.org/geos/geos-3.6.3.tar.bz2 \
    && tar -xjvf geos-3.6.3.tar.bz2 \
    && cd geos-3.6.3 \
    && ./configure --enable-php \
        --disable-swig \
        --disable-static \
    && make install-strip \
    && echo 'extension=geos.so' > /usr/local/etc/php/conf.d/geos.ini \
    && cd .. && rm -rf geos-3.6.3

# PHP BINDINGS FOR PAIN IN THE ASS GEOS
#
RUN apt-get update && apt-get install -y -q --no-install-recommends git
RUN find / -name geos_c.h
RUN git clone https://git.osgeo.org/gitea/geos/php-geos.git \
    && cd php-geos \
    && ./autogen.sh \
    && ./configure --enable-geos \
    && make \
    && make install

# git rid of git
RUN apt-get remove -y git
RUN apt-get purge -y --auto-remove && rm -rf /var/lib/apt/lists/*
RUN rm -rf /var/www/html/*

# Clean
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/*

