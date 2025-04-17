#!/bin/bash

# ----------------------------------------
# Function: Change Timezone to HCM
# ----------------------------------------
function changeTimezone() {
    # Check if the script is run as root
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root"
        exit 1
    fi
    
    TIMEZONE="Asia/Ho_Chi_Minh"
    sudo timedatectl set-timezone "$TIMEZONE"
}