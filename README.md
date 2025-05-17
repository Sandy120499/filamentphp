# Filament Demo App

A demo application to illustrate how Filament Admin works.

![Filament Demo](https://github.com/filamentphp/demo/assets/171715/899161a9-3c85-4dc9-9599-13928d3a4412)

[Open in Gitpod](https://gitpod.io/#https://github.com/filamentphp/demo) to edit it and preview your changes with no setup required.

## Installation

Clone the repo locally:

```
git clone git clone https://github.com/Sandy120499/filamentphp && cd filament
```

```
docker-compose pull
```
```
docker-compose pull && docker-compose up --build
```

```
docker exec -it <container_name> bash
```

```sh
composer install
php artisan migrate
```

Setup configuration:

```sh
cp .env.example .env
```

Generate application key:

```sh
php artisan key:generate
```


