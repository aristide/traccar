#!/bin/bash

SETUP_FOLDER="$HOME/setup"

# Generate SSH private key file
eval $(ssh-agent -s)
echo "$SSH_PRIVATE_KEY" | tr -d '\r' | ssh-add -
echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > $HOME/.ssh/config

# Run any other desired command here
exec "$@"