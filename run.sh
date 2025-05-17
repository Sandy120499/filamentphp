#!/bin/bash

docker exec -it filamentphp_app_1 composer install

docker exec -it filamentphp_app_1 php artisan migrate:fresh --seed

docker exec -it filamentphp_app_1 chown -R www-data:www-data /var/www/html
