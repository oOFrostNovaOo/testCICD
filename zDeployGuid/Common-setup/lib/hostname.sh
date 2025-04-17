#!/bin/bash

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
    read -p "Press any key to continue..."
}