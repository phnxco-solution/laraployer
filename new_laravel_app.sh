#!/bin/bash

# Function to print messages with spaces around them
print_message() {
  echo ""
  echo "$1"
  echo ""
}

# Trap errors and call the error_exit function
trap 'print_message "Error on line $LINENO"' ERR

# Check if the application name (subdomain) is provided
if [ -z "$1" ]; then
  print_message "Usage: $0 <application_name(subdomain)> <github_repo_url>"
  exit 1
fi

# Check if the GitHub repository URL is provided
if [ -z "$2" ]; then
  print_message "Usage: $0 <application_name(subdomain)> <github_repo_url>"
  exit 1
fi

# Load environment variables from .env file
if [ -f .env ]; then
  export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
else
  echo ".env file not found!"
  exit 1
fi

# Configure script variables
APP_NAME=$1
PRETTY_APP_NAME=$(echo "${APP_NAME}" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2));} 1')
GITHUB_REPO_URL=$2
DOMAIN="${APP_NAME}.${TOP_DOMAIN}"
ROOT_DIR="${WWW_DIR}/${DOMAIN}"
APP_ROOT_DIR="${ROOT_DIR}/public_html"
NGINX_AVAILABLE="/etc/nginx/sites-available/${DOMAIN}"
NGINX_ENABLED="/etc/nginx/sites-enabled/${DOMAIN}"
DB_NAME=$(echo "$APP_NAME" | tr '[:upper:]' '[:lower:]' | tr '-' '_')
SCRIPT_DIR=$(pwd)
CURRENT_USER=$(whoami)

# Include helper scripts
source ${SCRIPT_DIR}/helpers/dir_structure_and_cloning.sh
source ${SCRIPT_DIR}/helpers/laravel_initialization.sh
source ${SCRIPT_DIR}/helpers/nginx_configuration.sh

print_message "The application ${DOMAIN} has been set up and configured."
