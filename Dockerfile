FROM php:apache-bullseye
LABEL maintainer="Chris Kankiewicz <Chris@ChrisKankiewicz.com>"

ENV HOME="/tmp"
ENV COMPOSER_HOME="/tmp"
ENV XDG_CONFIG_HOME="/tmp/.config"
ENV VERSION=3.12.3

COPY --from=composer:2.3 /usr/bin/composer /usr/bin/composer
COPY --from=node:18.4 /usr/local/bin/node /usr/local/bin/node
COPY --from=node:18.4 /usr/local/lib/node_modules /usr/local/lib/node_modules

RUN ln --symbolic ../lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && ln --symbolic ../lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx

RUN apt-get update && apt-get install --assume-yes --no-install-recommends \
    libmemcached-dev libzip-dev tar zip \
    && rm -rf /var/lib/apt/lists/*

# RUN docker-php-ext-install opcache zip \
#     && pecl install apcu memcached redis xdebug \
#     && docker-php-ext-enable apcu memcached redis xdebug


RUN docker-php-ext-install opcache zip
RUN pecl install apcu
RUN pecl install memcached
RUN pecl install redis
RUN pecl install xdebug
RUN docker-php-ext-enable apcu
RUN docker-php-ext-enable memcached
RUN docker-php-ext-enable redis
RUN docker-php-ext-enable xdebug


RUN a2enmod rewrite

COPY .docker/apache2/config/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY .docker/php/config/php.ini /usr/local/etc/php/php.ini

RUN apt update && apt install -y libzip-dev wget
RUN rm -rf /var/lib/apt/lists/*
RUN pecl install zip
RUN docker-php-ext-enable zip
RUN wget https://github.com/DirectoryLister/DirectoryLister/releases/download/${VERSION}/DirectoryLister-${VERSION}.tar.gz -O - | tar -xz
RUN chown -R 33:33 /var/www/html
RUN rm /var/www/html/LICENSE
RUN rm /var/www/html/directory-lister.svg
RUN rm /var/www/html/README.md
