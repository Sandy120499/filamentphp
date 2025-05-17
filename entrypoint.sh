#!/bin/bash

# Run Composer install (if not already done in image build)
composer install

# Set ownership
chown -R www-data:www-data /var/www/html

# Run Laravel migrations
php artisan migrate
php artisan migrate:fresh --seed

# Start Apache in the foreground (important!)
exec apache2-foreground
