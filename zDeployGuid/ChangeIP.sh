#!/bin/bash

# Backup existing Netplan configuration
NETPLAN_CONFIG="/etc/netplan/00-installer-config.yaml"
BACKUP_CONFIG="/etc/netplan/00-installer-config.yaml.bak"

if [ -f "$NETPLAN_CONFIG" ]; then
    echo "Backing up existing Netplan configuration..."
    sudo cp "$NETPLAN_CONFIG" "$BACKUP_CONFIG"
fi

# Define the static IP configuration
STATIC_IP="192.168.1.201"
GATEWAY="192.168.11.1"
DNS="8.8.8.8"
INTERFACE=$(ip -o -4 route show to default | awk '{print $5}')

if [ -z "$INTERFACE" ]; then
    echo "No network interface detected. Exiting."
    exit 1
fi

# Write the new Netplan configuration
echo "Writing new Netplan configuration..."
cat > $NETPLAN_CONFIG <<EOL
network:
  version: 2
  renderer: networkd
  ethernets:
    $INTERFACE:
      addresses:
        - $STATIC_IP/24
      gateway4: $GATEWAY
      nameservers:
        addresses:
          - $DNS
EOL

# Apply the new configuration
echo "Applying Netplan configuration..."
netplan apply

echo "Static IP configuration applied successfully."