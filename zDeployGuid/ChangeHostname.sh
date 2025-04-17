#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

# Get the new hostname from the user
read -p "Enter the new hostname: " NEW_HOSTNAME

# Validate input
if [[ -z "$NEW_HOSTNAME" ]]; then
    echo "Hostname cannot be empty."
    exit 1
fi

# Change the hostname temporarily
hostnamectl set-hostname "$NEW_HOSTNAME"

# Update /etc/hostname
echo "$NEW_HOSTNAME" > /etc/hostname

# Update /etc/hosts
sed -i "s/127.0.1.1.*/127.0.1.1 $NEW_HOSTNAME/" /etc/hosts

echo "Hostname has been changed to '$NEW_HOSTNAME' permanently."