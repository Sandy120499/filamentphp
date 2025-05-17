FROM php:8.3-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libzip-dev zip unzip \
    libpng-dev libjpeg-dev libfreetype6-dev \
    libicu-dev libexif-dev \
    && docker-php-ext-install \
    pdo pdo_mysql zip gd intl exif pcntl

# Set working directory
WORKDIR /var/www/html

# Copy Laravel files
COPY . .

# Set Apache to serve the /public folder
RUN sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/public|g' /etc/apache2/sites-available/000-default.conf \
    && a2enmod rewrite

# Set permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install Laravel dependencies
RUN composer install --optimize-autoloader --no-dev

WORKDIR /var/www/html

RUN composer install \
    && chown -R www-data:www-data /var/www/html

RUN php artisan migrate

