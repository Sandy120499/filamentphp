#!/bin/bash

# Run Composer install (if not already done in image build)
composer install

# Run Laravel migrations
php artisan migrate

# Set ownership
chown -R www-data:www-data /var/www/html

php artiran migrate:fresh --seed

# Start Apache in the foreground (important!)
exec apache2-foreground
