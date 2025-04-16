#!/bin/bash

# Script to change the system timezone to Ho Chi Minh City

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

# Set timezone to Ho Chi Minh City
TIMEZONE="Asia/Ho_Chi_Minh"

# Check if the timezone exists
if [ ! -f "/usr/share/zoneinfo/$TIMEZONE" ]; then
    echo "Timezone $TIMEZONE does not exist."
    exit 1
fi

# Change the timezone
ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
echo "$TIMEZONE" > /etc/timezone

# Restart services to apply changes
if command -v systemctl &> /dev/null; then
    systemctl restart systemd-timedated
fi

echo "Timezone changed to $TIMEZONE successfully."