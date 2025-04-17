#!/bin/bash

# =========================================
# Author: Minh Nguyen
# Description: Bash script to manage system configs
# Functions: change IP, timezone, and hostname
# =========================================

set -e

# Colors
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

function log_info() {
    echo -e "${GREEN}[INFO] $1${RESET}"
}

function log_warn() {
    echo -e "${YELLOW}[WARN] $1${RESET}"
}

function log_error() {
    echo -e "${RED}[ERROR] $1${RESET}"
}

# ----------------------------------------
# Function: Create SSH Key
# ----------------------------------------
function createSSHKeyAndDeploy() {
    KEY_PATH="$HOME/.ssh/id_rsa"
    
    # Kiểm tra SSH key có tồn tại chưa
    if [ ! -f "$KEY_PATH" ]; then
        log_info "No SSH key found. Generating new SSH key..."
        ssh-keygen -t rsa -b 4096 -f "$KEY_PATH" -N ""
        log_info "SSH key created at $KEY_PATH"
    else
        log_info "SSH key already exists at $KEY_PATH"
    fi

    # Nhập IP client
    read -p "Enter client IP to deploy public key (e.g., 192.168.1.10): " client_ip
    if [[ -z "$client_ip" ]]; then
        log_error "Client IP cannot be empty."
        return 1
    fi

    read -p "Enter username on the client [default: ubuntu]: " client_user
    client_user=${client_user:-ubuntu}

    # Copy public key đến client
    log_info "Deploying SSH public key to ${client_user}@${client_ip}..."
    ssh-copy-id "${client_user}@${client_ip}"

    if [ $? -eq 0 ]; then
        log_info "SSH key deployed successfully. You can now connect without password:"
        echo "    ssh ${client_user}@${client_ip}"
    else
        log_error "Failed to deploy SSH key. Check connection or credentials."
    fi
}


# ----------------------------------------
# Function: Change Timezone to HCM
# ----------------------------------------
function changeTimezone() {
    TIMEZONE="Asia/Ho_Chi_Minh"
    sudo timedatectl set-timezone "$TIMEZONE"
    log_info "Timezone changed to $TIMEZONE"
}

# ----------------------------------------
# Function: Change Hostname
# ----------------------------------------
function changeHostname() {
    read -p "Enter new hostname: " new_hostname
    if [ -z "$new_hostname" ]; then
        log_error "Hostname cannot be empty."
        exit 1
    fi
    sudo hostnamectl set-hostname "$new_hostname"
    log_info "Hostname changed to $new_hostname"
}

# ----------------------------------------
# Main Menu
# ----------------------------------------
function show_menu() {
    echo "========= System Configuration Script ========="
    echo "1) Change IP Address"
    echo "2) Change Timezone to Ho Chi Minh City"
    echo "3) Change Hostname"
    echo "4) Create SSH Key & Deploy to Client"
    echo "0) Exit"
    echo "==============================================="
}

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
    suggested_dns="8.8.8.8"
    read -p "Enter DNS server (e.g., 8.8.8.8, 1.1.1.1): " dns
    dns=${dns:-$suggested_dns}

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
}

# ----------------------------------------
# Main script execution
# ----------------------------------------
while true; do
    show_menu
    read -p "Select an option [1-4]: " choice
    case $choice in
        1) changeIP ;;
        2) changeTimezone ;;
        3) changeHostname ;;
        4) createSSHKeyAndDeploy ;;
        0) log_info "Exiting script." ; exit 0 ;;
        *) log_warn "Invalid option. Please choose 1-5." ;;
    esac

done
# End of script