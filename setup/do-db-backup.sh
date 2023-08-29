#!/bin/bash

# Backup Directory
BACKUP_DIR="/tmp/mysql_backups"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Get current timestamp
TIMESTAMP=$(date +%Y%m%d%H%M%S)

# Backup MySQL database
mysqldump -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" > "$BACKUP_DIR/$DB_NAME-$TIMESTAMP.sql"

# Upload backup to DigitalOcean Spaces
s3cmd put --access_key="$DO_ACCESS_KEY" --secret_key="$DO_SECRET_KEY" "$BACKUP_DIR/$DB_NAME-$TIMESTAMP.sql" "s3://$DO_BUCKET_NAME/$DB_NAME-$TIMESTAMP.sql"

# Clean up local backup
rm "$BACKUP_DIR/$DB_NAME-$TIMESTAMP.sql"
