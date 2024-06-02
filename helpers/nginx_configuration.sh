# Create the NGINX configuration file
print_message "Creating the NGINX configuration file..."

sudo tee ${NGINX_AVAILABLE} > /dev/null <<EOL
server {
    listen 80;
    listen [::]:80;
    server_name ${DOMAIN};

    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name ${DOMAIN};
    root ${APP_ROOT_DIR}/public;

    ssl_certificate /etc/letsencrypt/live/phnx-solution.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/phnx-solution.com/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php\$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_hide_header X-Powered-By;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }

    location /.well-known/acme-challenge/ {
        root ${APP_ROOT_DIR}/public;
    }
}
EOL

# Enable the site by creating a symbolic link
print_message "Enabling the site ${DOMAIN}..."
sudo ln -s ${NGINX_AVAILABLE} ${NGINX_ENABLED}

# Test the NGINX configuration
print_message "Testing the NGINX configuration..."
sudo nginx -t

# Reload NGINX to apply the changes
print_message "Reloading NGINX..."
sudo systemctl reload nginx
