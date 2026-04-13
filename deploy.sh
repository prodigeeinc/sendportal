#!/bin/bash

set -e  # Exit on error

# ===== CONFIG =====
COMPOSE_FILE="docker-compose.yml"
APP_SERVICE="sendportal"
CONTAINER_NAME="sendportal_app"

# ===== BUILD & START CONTAINERS =====
echo "📦 Building and starting containers..."
docker compose -f $COMPOSE_FILE up -d --build

# ===== WAIT FOR APP CONTAINER =====
echo "⏳ Waiting for app container to be ready..."
sleep 10

# Optional: wait until container is healthy (better approach)
# until docker exec $CONTAINER_NAME php -v >/dev/null 2>&1; do
#   echo "Waiting for PHP container..."
#   sleep 2
# done

# ===== RUN LARAVEL COMMANDS =====
echo "⚙️ Running Laravel post-install commands..."

docker exec -it $CONTAINER_NAME php artisan config:clear
docker exec -it $CONTAINER_NAME php artisan cache:clear

# Publish package assets 
docker exec -it $CONTAINER_NAME php artisan vendor:publish --provider=Sendportal\\Base\\SendportalBaseServiceProvider

# Example: run migrations if needed
docker exec -it $CONTAINER_NAME php artisan migrate --force

echo "✅ Deployment complete!" 
