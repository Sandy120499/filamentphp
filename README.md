# Filament Demo App

A demo application to illustrate how Filament Admin works.

![Filament Demo](https://github.com/filamentphp/demo/assets/171715/899161a9-3c85-4dc9-9599-13928d3a4412)

[Open in Gitpod](https://gitpod.io/#https://github.com/filamentphp/demo) to edit it and preview your changes with no setup required.

## Installation

```
yum install git docker libxcrypt-compat -y
systemctl status docker
systemctl start docker
systemctl enable docker
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

Clone the repo locally:

```
git clone https://github.com/Sandy120499/filamentphp && cd filamentphp
```

```
docker-compose pull
```
```
docker-compose up -d --build
```

```
docker exec -it <container_name> bash
```

```sh
composer install
```

```
chown -R www-data:www-data /var/www/html
```

```
php artisan migrate
```
```
php artisan migrate:fresh --seed
```

Generate application key:

```
php artisan key:generate
```


