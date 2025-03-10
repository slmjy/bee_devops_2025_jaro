FROM php:8.3-fpm

ARG user
ARG uid
ARG laravel_env

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    postgresql \
    postgresql-client \
    libpq-dev \
    jpegoptim  \
    optipng  \
    pngquant  \
    gifsicle \
    libc-client-dev \
    libkrb5-dev

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_pgsql mbstring exif pcntl bcmath gd zip
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl
RUN docker-php-ext-install imap

# install xdebug only when on local env
RUN if [ "$laravel_env" = "local" ]; then \
	pecl install xdebug-3.4.1 && docker-php-ext-enable xdebug \
	; fi

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy php.ini configuration
COPY docker-compose/php.ini /usr/local/etc/php/php.ini

# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user && \
    chown -R $uid:$uid /var/www

ARG NODE_VERSION="18.18.2"
RUN curl https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz | tar -xz -C /usr/local --strip-components 1

# Set working directory
WORKDIR /var/www

USER $user
