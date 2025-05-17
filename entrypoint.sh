#!/bin/bash

# Run Composer install (if not already done in image build)
composer install

# Run Laravel migrations
php artisan migrate
php artisan migrate:fresh --seed

# Set ownership
chown -R www-data:www-data /var/www/html

php artisan migrate:db --seed

# Start Apache in the foreground (important!)
exec apache2-foreground
