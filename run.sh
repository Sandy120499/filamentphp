#!/bin/bash

composer install

php artisan migrate

php artisan migrate:fresh --seed

chown -R www-data:www-data /var/www/html
