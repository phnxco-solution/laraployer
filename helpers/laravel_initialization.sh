# Initialize Laravel application
print_message "Initializing Laravel application..."

# Copy .env.example to .env
sudo -u ${APP_OWNER} cp ${APP_ROOT_DIR}/.env.example ${APP_ROOT_DIR}/.env

# Populate the .env file with specified fields
sudo sed -i "s/APP_NAME=.*/APP_NAME=\"${PRETTY_APP_NAME}\"/" ${APP_ROOT_DIR}/.env
sudo sed -i "s|APP_URL=.*|APP_URL=https://${DOMAIN}|" ${APP_ROOT_DIR}/.env
sudo sed -i "s|SCHEDULER_TIMEZONE=.*|SCHEDULER_TIMEZONE=\"UTC\"|" ${APP_ROOT_DIR}/.env
sudo sed -i "s/DB_DATABASE=.*/DB_DATABASE=${DB_NAME}/" ${APP_ROOT_DIR}/.env
sudo sed -i "s/DB_USER=.*/DB_USER=${DB_USER}/" ${APP_ROOT_DIR}/.env
sudo sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=${DB_PASSWORD}/" ${APP_ROOT_DIR}/.env

# Create the database
print_message "Creating the database ${DB_NAME}..."
DB_CREATION_OUTPUT=$(sudo mysql -u root -e "CREATE DATABASE ${DB_NAME};" 2>&1) || true
if [[ ${DB_CREATION_OUTPUT} == *"database exists"* ]]; then
  print_message "Database ${DB_NAME} already exists. Skipping database creation."
else
  print_message "Database ${DB_NAME} created successfully."
fi

# Install Laravel dependencies
print_message "Installing Laravel dependencies..."
cd ${APP_ROOT_DIR}
sudo -u ${APP_OWNER} composer install

# Laravel setup
print_message "Finishing Laravel setup"
sudo -u ${APP_OWNER} php artisan key:generate
sudo -u ${APP_OWNER} php artisan storage:link
sudo -u ${APP_OWNER} php artisan migrate:fresh --seed
sudo -u ${APP_OWNER} php artisan optimize

# Settings permissions
sudo chown -R ${APP_OWNER}:${APP_OWNER} ${APP_ROOT_DIR}/storage ${APP_ROOT_DIR}/bootstrap/cache
sudo chmod -R 775 ${APP_ROOT_DIR}/storage ${APP_ROOT_DIR}/bootstrap/cache
