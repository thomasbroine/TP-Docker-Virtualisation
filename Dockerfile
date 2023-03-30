FROM php:8.2-apache

RUN docker-php-ext-install pdo pdo_pgsql
RUN pecl install xdebug && docker-php-ext-enable xdebug

COPY . /var/www/html/