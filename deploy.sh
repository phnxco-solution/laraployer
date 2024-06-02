#!/bin/sh

set -e

# Function to print messages with spaces around them
print_message() {
  echo ""
  echo "$1"
  echo ""
}

# Configure variables
GIT_BRANCH=master
DOMAIN=$1

print_message "Deployment started ..."

cd /var/www/${DOMAIN}/public_html

(php artisan down) || true

git pull origin ${GIT_BRANCH}

composer update && print_message "Composer update  - OK"

php artisan migrate:fresh --seed && print_message "Migration and Seeding - OK"

php artisan cache:clear && print_message "App cache cleared - OK"

php artisan config:clear && print_message "Config cache cleared - OK"

php artisan view:clear && print_message "View cache cleared - OK"

php artisan optimize:clear && print_message "Optimized clear - OK"

php artisan optimize && print_message "Optimized - OK"

php artisan up

print_message "Deployment finished!"
