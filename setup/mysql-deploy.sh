#!/bin/bash

# Read configuration from environment variables
#export ROOT_PASSWORD="&234PAsse12"
#export DEFAULT_USER="tracking_user"
#export DEFAULT_USER_PASSWORD="@er2ErErsd333"
#export DEFAULT_DATABASE="trackingdb"

# Install MySQL Server 8
sudo apt update
sudo apt install -y mysql-server

# Start MySQL service
sudo systemctl start mysql
sudo systemctl enable mysql

# Generate SQL commands to configure MySQL
SQL_COMMANDS="
ALTER USER 'root'@'localhost' IDENTIFIED WITH 'mysql_native_password' BY '$ROOT_PASSWORD';
CREATE USER '$DEFAULT_USER'@'localhost' IDENTIFIED WITH 'mysql_native_password' BY '$DEFAULT_USER_PASSWORD';
CREATE DATABASE $DEFAULT_DATABASE;
GRANT ALL PRIVILEGES ON $DEFAULT_DATABASE.* TO '$DEFAULT_USER'@'localhost';
FLUSH PRIVILEGES;
"

# Execute SQL commands
echo "$SQL_COMMANDS" | sudo mysql -u root -p"$ROOT_PASSWORD"

# Clean up
unset ROOT_PASSWORD DEFAULT_USER DEFAULT_USER_PASSWORD DEFAULT_DATABASE SQL_COMMANDS

echo "MySQL deployment and configuration completed."
