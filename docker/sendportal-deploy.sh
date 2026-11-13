#!/bin/sh
set -eu

cd /var/www/html

echo "[deploy] Waiting for database..."
i=0
max=60
until php artisan db:show --no-interaction >/dev/null 2>&1; do
  i=$((i + 1))
  if [ "$i" -ge "$max" ]; then
    echo "[deploy] Database not ready after ${max}s" >&2
    exit 1
  fi
  sleep 1
done
echo "[deploy] Database is ready"

echo "[deploy] Clearing config and cache..."
php artisan config:clear --no-interaction
php artisan cache:clear --no-interaction

echo "[deploy] Running migrations..."
php artisan migrate --force --no-interaction

echo "[deploy] Caching config..."
php artisan config:cache --no-interaction

echo "[deploy] Complete"
