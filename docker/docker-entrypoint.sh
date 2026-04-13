#!/bin/sh
set -e
# Named volumes often mount as root; artisan/php-fpm run as www-data. Normalize ownership
# on every start so logs, cache, sessions, and uploads remain writable.
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
chmod -R ug+rwx /var/www/html/storage /var/www/html/bootstrap/cache
exec /usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf
