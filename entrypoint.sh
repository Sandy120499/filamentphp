sleep 10

# 1. Enter the container
docker exec -it filamentphp_app_1 bash

# 2. (Optional) Re-run composer install in case of any volume sync overrides
composer install

# 3. Ensure correct permissions (in case volumes override Dockerfile permissions)
chown -R www-data:www-data /var/www/html

# 4. Run Laravel migrations
php artisan migrate

# 5. (Optional) Seed the database
php artisan migrate:fresh --seed
