#!/bin/bash

# Default values
USER="ubuntu"
KEY_PATH="$HOME/.ssh/id_rsa.pub"
INVENTORY_FILE="./inventory"
GROUP_NAME="workers"

# Logging functions
log_info() { echo -e "\e[32m[INFO]\e[0m $1"; }
log_error() { echo -e "\e[31m[ERROR]\e[0m $1"; }

# Help
usage() {
    echo "Usage: $0 [--user <username>] [--key <path_to_pub_key>] [--inventory <inventory_file>] [--group <group_name>]"
    echo "Example: $0 --user ubuntu --key ~/.ssh/id_rsa.pub --inventory ./hosts.ini --group workers"
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

# Deploy key
log_info "Deploying public key [$KEY_PATH] to group [$GROUP_NAME] in inventory [$INVENTORY_FILE]..."

in_group=false

while IFS= read -r line; do
    [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue

    if [[ "$line" == \[$GROUP_NAME\] ]]; then
        in_group=true
        continue
    fi

    if [[ "$line" =~ ^\[.*\] ]]; then
        in_group=false
    fi

    if $in_group; then
        ip=$(echo "$line" | grep -oP 'ansible_host=\K[\d.]+')
        if [ -n "$ip" ]; then
            log_info "Deploying key to $USER@$ip"
            ssh-copy-id -i "$KEY_PATH" "$USER@$ip"
        fi
    fi
done < "$INVENTORY_FILE"

log_info "✅ Done deploying public key to [$GROUP_NAME] nodes."
