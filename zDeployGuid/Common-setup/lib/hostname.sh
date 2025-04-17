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
    
    read -p "Enter new hostname: " new_hostname
    if [ -z "$new_hostname" ]; then
        log_error "Hostname cannot be empty."
        exit 1
    fi
    sudo hostnamectl set-hostname "$new_hostname"
    log_info "Hostname changed to $new_hostname"
    read -p "Press any key to continue..."
}