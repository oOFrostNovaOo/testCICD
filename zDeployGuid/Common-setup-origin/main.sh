#!/bin/bash

# =========================================
# Author: Minh Nguyen
# Description: Bash script to manage system configs
# Functions: change IP, timezone, and hostname
# =========================================
# Run this script with root privileges
# chmod +x main.sh lib/*.sh
# sudo ./main.sh
# =========================================

#load library functions
#source ./lib/load_env.sh
source ./lib/network.sh
source ./lib/install_docker.sh
source ./lib/install_terraform.sh
source ./lib/ansible_implement.sh
source ./lib/install_ansible.sh


# Check if the script is run as root
# if [ "$EUID" -ne 0 ]; then
#     echo "Please run as root"
#     exit 1
# fi

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
    echo ""
    echo ""
    echo "==============================================="
    echo "========= System Configuration Script ========="
    echo "1) Install Ansible"
    echo "2) Change IP this machine"
    echo "3) Ansible: Set IP address for clients"
    echo "4) Deploy SSH key + Change Hostname + Change Timezone"
    echo "5) Install Docker && setup Docker Swarm"
    echo "6) Install Terraform"
    echo "7) "
    echo ""

    echo "0) Exit"
    echo "==============================================="
}

# ----------------------------------------
# Main script execution
# ----------------------------------------
log_info "Starting checking dependencies..."
#load_env
echo ""
echo '============================'
while true; do    
    show_menu    
    read -p "Select an option [0-9]: " choice
    case $choice in
        1)
            log_info "Installing Ansible..."
            install_ansible
            read -p "Press any key to exit..."
            exit 0
            ;;			
        2)            
            log_info "Changing IP address..."
            changeIP   
            hostname -I
			read -p "Press any key to continue..."
			;;
        3)  
            ansible_change_IP
			log_info "IP address updated successfully."
			read -p "Press any key to continue..."
            ;;
        4)
            log_info "Deploy SSHkey..."
            deploy_sshKey            
            log_info "Changing Hostname and Timezone..."
            ansible_change_hostname_timezone
            log_info "Hostname and Timezone updated successfully."
            read -p "Press any key to continue..."
            ;;
        5)
            log_info "Setupping Docker Swarm..."
            implement_Docker_swarm
            log_info "5..."
            read -p "Press any key to continue..."            
            ;;
        6)
            log_info "Installing Terraform..."
            install_terraform
            log_info "Terraform installed successfully."
            read -p "Press any key to continue..."
            ;;                 

        0) log_info "Exiting script." ; exit 0 ;;
        *) log_warn "Invalid option. Please choose 1-5." ;;
    esac

done
# End of script
