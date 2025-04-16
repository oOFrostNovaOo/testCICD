#!/bin/bash

# Check if the server address is provided as an argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <server_address>"
    exit 1
fi

SERVER_ADDRESS=$1

# Generate SSH key pair if it doesn't exist
SSH_KEY="$HOME/.ssh/id_rsa"
if [ ! -f "$SSH_KEY" ]; then
    echo "Generating SSH key pair..."
    ssh-keygen -t rsa -b 4096 -f "$SSH_KEY" -N ""
else
    echo "SSH key pair already exists at $SSH_KEY"
fi

# Copy the public key to the server
echo "Copying public key to $SERVER_ADDRESS..."
ssh-copy-id -i "$SSH_KEY.pub" "ubuntu@$SERVER_ADDRESS"

echo "SSH key successfully copied to $SERVER_ADDRESS."