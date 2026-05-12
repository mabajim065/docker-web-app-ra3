#!/bin/bash

# Database backup script
# Uses docker exec to run mysqldump inside the db container
# and saves the output as a .sql file in the local ./backups folder

# Variables
CONTAINER_NAME="db"
BACKUP_DIR="./backups"
DATE=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/backup_$DATE.sql"

# Load environment variables from .env file
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

# Create backups folder if it doesn't exist
mkdir -p "$BACKUP_DIR"

echo "Starting backup of database '$MYSQL_DATABASE'..."

# Run mysqldump inside the container
docker exec "$CONTAINER_NAME" mysqldump \
    -u root \
    -p"$MYSQL_ROOT_PASSWORD" \
    "$MYSQL_DATABASE" > "$BACKUP_FILE"

# Check if backup was successful
if [ $? -eq 0 ]; then
    echo "Backup completed successfully: $BACKUP_FILE"
else
    echo "Backup failed!"
    exit 1
fi