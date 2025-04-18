#!/bin/bash

# ----------------------------------------
# Function: Change Hostname
# ----------------------------------------
function changeHostname() {
    # Check if the script is run as root
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root"
        exit 1
    fi
    
    # Thay đổi hostname
    log_info "Changing hostname ..."
    sudo hostnamectl set-hostname "$HOSTNAME"
    log_info "Hostname changed successfully."
    hostname 
    echo ""
}