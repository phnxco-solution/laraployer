# Create the folder structure
print_message "Creating the folder structure for ${DOMAIN}..."
sudo mkdir -p ${APP_ROOT_DIR}

# Set ownership and permissions
sudo chown -R ${APP_OWNER}:${APP_OWNER} ${ROOT_DIR}
sudo chmod -R 755 ${ROOT_DIR}

# Clone the GitHub repository
print_message "Cloning the GitHub repository..."
sudo -u ${APP_OWNER} git clone ${GITHUB_REPO_URL} ${APP_ROOT_DIR}

# Set ownership and permissions again after cloning
sudo chown -R ${APP_OWNER}:${APP_OWNER} ${ROOT_DIR}
sudo chmod -R 755 ${ROOT_DIR}
