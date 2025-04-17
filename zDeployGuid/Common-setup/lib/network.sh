#!/bin/bash

# ----------------------------------------
# Function: Change IP address (Ubuntu netplan)
# ----------------------------------------
function changeIP() {
    # Check NIC name
    default_iface=$(ip route | awk '/default/ {print $5}' | head -n 1)
    read -p "Detected interface is '$default_iface'. Press Enter to accept or enter a different name: " iface
    iface=${iface:-$default_iface}

    #Type of IP address
    read -p "Enter new static IP address (e.g., 192.168.1.100): " new_ip
    #read -p "Enter Subnet Prefix (e.g., 24 for 255.255.255.0): " prefix

    # Suggest default gateway
    IFS='.' read -ra ip_parts <<< "$new_ip"
    suggested_gw="${ip_parts[0]}.${ip_parts[1]}.${ip_parts[2]}.1"
    read -p "Default gateway [${suggested_gw}]: " gateway
    gateway=${gateway:-$suggested_gw}

    # Suggest DNS server    
    read -p "Enter DNS server (default: 8.8.8.8): " dns
    dns=${dns:-"8.8.8.8"}

    # Find netplan config file
    NETPLAN_FILE=$(find /etc/netplan -name "*.yaml" | head -n 1)

    if [ -z "$NETPLAN_FILE" ]; then
        log_error "No netplan config found."
        exit 1
    fi

    log_info "Updating Netplan config: $NETPLAN_FILE"

    cat <<EOF | sudo tee "$NETPLAN_FILE" > /dev/null
        network:
        version: 2
        renderer: networkd
        ethernets:
            $iface:
            dhcp4: no
            addresses: [$new_ip/24]
            gateway4: $gateway
            nameservers:
                addresses: [$dns]
    EOF

    sudo netplan apply
    log_info "IP address updated successfully."
    readp -p "Press any key to continue..."
}