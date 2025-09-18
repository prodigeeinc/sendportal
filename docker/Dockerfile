# syntax=docker/dockerfile:experimental
FROM composer:2.4 AS composer
WORKDIR /app
COPY --chown=www-data composer.json /app/
RUN --mount=type=cache,target=/.composer/cache composer install --no-autoloader --no-scripts \
    --ignore-platform-reqs \
    --no-interaction \
    --no-plugins \
    --no-scripts \
    --prefer-dist
COPY . /app/
RUN composer dump-autoload


# FROM node:22-alpine as frontend
# WORKDIR /app
# COPY resources/ ./resources/
# COPY Modules ./Modules/
# COPY package.json ./package.json
# COPY tailwind.config.js ./tailwind.config.js
# COPY tsconfig.json ./tsconfig.json
# COPY postcss.config.js ./postcss.config.js
# COPY vite.config.js ./vite.config.js
# COPY --from=composer --chown=www-data /app/vendor/ ./vendor
# RUN npm install -g npm@latest && \
#     npm install --no-progress && \
#     npm run build --no-progress


FROM php:8.3-fpm-alpine as production

# Install system dependencies
RUN apk update && apk upgrade && \
    apk add --no-cache \
    nginx \
    supervisor \
    cronie \
    mysql-client \
    git \
    libxml2-dev \
    libzip-dev \
    postgresql-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    icu-dev \
    g++ \
    make \
    autoconf \
    imagemagick-dev

# Install PHP extensions
RUN docker-php-ext-install -j$(nproc) intl opcache zip pdo pdo_mysql pdo_pgsql mysqli exif pcntl posix

# Enable opcache
# COPY --from=composer /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini /usr/local/etc/php/conf.d/

# Install redis extension
RUN pecl install redis && docker-php-ext-enable redis

# Set up Nginx configuration
COPY docker/nginx.conf /etc/nginx/http.d/default.conf

# Set up working directory
WORKDIR /var/www/html
COPY --chown=www-data . /var/www/html/
COPY --from=composer --chown=www-data /app/vendor/ /var/www/html/vendor/
# COPY --from=frontend --chown=www-data /app/public/build/ /var/www/html/public/build/

# Set permissions for storage and bootstrap cache directories
RUN chown -R www-data:www-data /var/www/html/storage \
    && chmod -R 775 /var/www/html/storage \
    && chown -R www-data:www-data /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/bootstrap/cache

# Add cron jobs for Laravel scheduler and Sendportal campaign dispatch
# RUN echo '* * * * * www-data php /var/www/html/artisan schedule:run >> /dev/null 2>&1' >> /etc/crontabs/www-data \
#     && echo '* * * * * www-data php /var/www/html/artisan sp:campaigns:dispatch >> /dev/null 2>&1' >> /etc/crontabs/www-data \
#     && chmod 0644 /etc/crontabs/www-data
    
# Copy Supervisor and PHP configurations
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker/php.ini /usr/local/etc/php/conf.d/php.ini
COPY docker/opcache.ini /usr/local/etc/php/conf.d/opcache.ini
# Expose port for Nginx
EXPOSE 9000

# Command to start supervisor
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]