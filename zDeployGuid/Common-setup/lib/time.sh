#!/bin/bash

# ----------------------------------------
# Function: Change Timezone to HCM
# ----------------------------------------
function changeTimezone() {
    TIMEZONE="Asia/Ho_Chi_Minh"
    sudo timedatectl set-timezone "$TIMEZONE"
}