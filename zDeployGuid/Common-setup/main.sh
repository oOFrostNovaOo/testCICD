#!/bin/bash

# =========================================
# Author: Minh Nguyen
# Description: Bash script to manage system configs
# Functions: change IP, timezone, and hostname
# =========================================
# Run this script with root privileges
# hmod +x main.sh lib/*.sh
# sudo ./main.sh
# =========================================

#load library functions
source ./lib/network.sh
source ./lib/hostname.sh
source ./lib/time.sh
source ./lib/createsshkey.sh
source ./lib/install_docker.sh
source ./lib/install_ansible.sh
source ./lib/install_terraform.sh

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

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
# Main Menu
# ----------------------------------------
function show_menu() {
    echo "========= System Configuration Script ========="
    echo "1) Change IP Address"
    echo "2) Change Timezone to Ho Chi Minh City"
    echo "3) Change Hostname"
    echo "4) Create SSH Key & Deploy to Client"
    echo "5) Install Ansible"
    echo "6) Install Docker && setup Docker Swarm"
    echo "7) Install Terraform"
    echo ""

    echo "0) Exit"
    echo "==============================================="
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
        5)
            log_info "Installing Ansible..."
            install_ansible
            ;;
        6)
            log_info "Setupping Docker Swarm..."
            implement_Docker_swarm
            ;;
        7)  
            log_info "Installing Terraform..."
            install_terraform
            ;;            

        0) log_info "Exiting script." ; exit 0 ;;
        *) log_warn "Invalid option. Please choose 1-5." ;;
    esac

done
# End of script
