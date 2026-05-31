FROM php:8.2-apache

# 1. Instalar dependencias del sistema (libpq-dev es crucial para PostgreSQL)
RUN apt-get update && apt-get install -y \
    libpq-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    git \
    curl \
    gnupg

# 2. Instalar extensiones de PHP (pdo_pgsql habilita la conexión con Postgres)
RUN docker-php-ext-install pdo pdo_pgsql mbstring exif pcntl bcmath gd

# 3. Instalar Composer desde la imagen oficial
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 4. Instalar Node.js (requerido para compilar Vite/Blade)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# 5. Configurar Apache para apuntar correctamente a la carpeta /public de Laravel
RUN sed -i 's|/var/www/html|/var/www/html/public|g' /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

# 6. Copiar los archivos del proyecto al espacio de trabajo del contenedor
COPY . /var/www/html

# 7. Asignar los permisos correctos a los directorios de escritura de Laravel
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# 8. Instalar dependencias de PHP (Ignorando restricciones de plataforma) y compilar Node
RUN composer install --no-dev --optimize-autoloader --ignore-platform-reqs
RUN npm install
RUN npm run build

# 9. Script de arranque para asegurar la ejecución de migraciones en cada despliegue
RUN echo '#!/bin/sh\n\
php artisan migrate --force\n\
apachectl -D FOREGROUND' > /usr/local/bin/start.sh

RUN chmod +x /usr/local/bin/start.sh

# Ejecutar el script automatizado al iniciar el contenedor
CMD ["/usr/local/bin/start.sh"]
