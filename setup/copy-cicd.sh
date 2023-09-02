#!/bin/bash

SETUP_FOLDER="$HOME/setup"

echo "Copy deployment files on $REMOTE_HOST server"
# Use scp command to copy  file to remote deployment folder
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null  \
    "$SETUP_FOLDER/maaeko-nginx.conf"  \
    "$SETUP_FOLDER/myadmin-nginx.conf"  \
    "$SETUP_FOLDER/supervisor-nginx.conf"  \
    "$SETUP_FOLDER/.mysql-env"  \
    "$SETUP_FOLDER/.backup-env"  \
    "$SETUP_FOLDER/.server-env"  \
    "$SETUP_FOLDER/.nginx-env"  \
    "$SETUP_FOLDER/.supervisor-env"  \
    "$SETUP_FOLDER/.init-env"  \
    "$SETUP_FOLDER/supervisor.conf"  \
    "$SETUP_FOLDER/do-db-backup.sh"  \
    "$SETUP_FOLDER/mysql-deploy.sh"  \
    "$SETUP_FOLDER/init-server.sh"  \
    "$REMOTE_USER@$REMOTE_HOST:/opt/deployment/"

echo "Copy application files on $REMOTE_HOST server"
# Use scp command to copy  file to remote root projet folder
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r \
    "$HOME/conf"  \
    "$HOME/schema"  \
    "$HOME/templates"  \
    "$HOME/modern"  \
    "$HOME/lib"  \
    "$HOME/atmmotors-server.jar"  \
    "$REMOTE_USER@$REMOTE_HOST:/opt/atmmotors/"
