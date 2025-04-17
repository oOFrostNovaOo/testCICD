#!/bin/bash

<<<<<<< HEAD
# Function: Deploy SSH Key to Remote Hosts
# This script deploys an SSH public key to a group of remote hosts defined in an Ansible inventory file.
# It uses ssh-copy-id to copy the public key to each host in the specified group.

function deploysshkey() {
    # Default values
    USER="ubuntu"
    KEY_PATH="$HOME/.ssh/id_rsa.pub"
    INVENTORY_FILE="./inventory.ini"
    GROUP_NAME="workers"

    # Help
    usage() {
        echo "Usage: $0 [--user <username>] [--key <path_to_pub_key>] [--inventory <inventory_file>] [--group <group_name>]"
        echo "Example: $0 --user ubuntu --key ~/.ssh/id_rsa.pub --inventory ./inventory.ini --group workers"
        exit 1
    }

    # Parse arguments
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --user) USER="$2"; shift ;;
            --key) KEY_PATH="$2"; shift ;;
            --inventory) INVENTORY_FILE="$2"; shift ;;
            --group) GROUP_NAME="$2"; shift ;;
            -h|--help) usage ;;
            *) log_error "Unknown parameter passed: $1"; usage ;;
        esac
        shift
    done

    # Check public key
    if [ ! -f "$KEY_PATH" ]; then
        log_error "SSH public key not found at $KEY_PATH"
        exit 1
    fi

    # Function to get worker IPs
    function get_worker_ips() {
        inventory_file="$1"
        group_name="$2"

        # Bước 1: Lấy danh sách host thuộc group
        hosts=$(ansible-inventory -i "$inventory_file" --list | \
                awk -v group="\\\"$group_name\\\"" '
                    $0 ~ group": {" {found=1; next}
                    found && /\]/ {exit}
                    found && /"/ {
                        gsub(/[",]/, "", $1)
                        print $1
                    }
                ')

        # Bước 2: Với mỗi host, tìm IP trong hostvars
        for host in $hosts; do
            ip=$(ansible-inventory -i "$inventory_file" --list | \
                awk -v host="\"$host\"" '
                    $0 ~ host": {" {found=1; next}
                    found && /ansible_host/ {
                        match($0, /[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/, m)
                        print m[0]
                        exit
                    }
                ')
            if [[ -n "$ip" ]]; then
                echo "$ip"
            fi
        done
    }

    # Deploy SSH key to the worker nodes
    log_info "Deploying public key [$KEY_PATH] to group [$GROUP_NAME] in inventory [$INVENTORY_FILE]..."

    worker_ips=$(get_worker_ips "$INVENTORY_FILE" "$GROUP_NAME")
    echo "Worker IPs: $worker_ips"

    for ip in $worker_ips; do
        echo "IP: $ip"
    done
    # Check if we found any IPs
    if [ -z "$worker_ips" ]; then
        log_error "No workers found in group $GROUP_NAME."
        exit 1
    fi

    # Deploy key to each worker
    for ip in $worker_ips; do
        log_info "Deploying key to $USER@$ip"
        ssh-copy-id -i "$KEY_PATH" "$USER@$ip"
        
        if [ $? -eq 0 ]; then
            log_info "Key deployed successfully to $USER@$ip"
        else
            log_error "Failed to deploy key to $USER@$ip"
        fi
    done

    log_info "✅ SSH key deployment completed."
}

# Example usage:
# deploysshkey --user ubuntu --key ~/.ssh/id_rsa.pub --inventory ./inventory.ini --group workers
