#!/bin/bash

# ----------------------------------------
# Function: Change Timezone to HCM
# ----------------------------------------
function changeTimezone() {
    TIMEZONE="Asia/Ho_Chi_Minh"
    sudo timedatectl set-timezone "$TIMEZONE"
    log_info "Timezone changed to $TIMEZONE"
    readp -p "Press any key to continue..."
}