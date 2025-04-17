#/bin/bash

# ----------------------------------------
# Function: Create SSH Key
# ----------------------------------------
function createSSHKeyAndDeploy() {
    # Xác định người dùng thật sự (kể cả khi chạy bằng sudo)
    REAL_USER=${SUDO_USER:-$USER}
    HOME_DIR=$(eval echo "~$REAL_USER")
    KEY_PATH="$HOME_DIR/.ssh/id_rsa"

    # Kiểm tra SSH key có tồn tại chưa
    if [ ! -f "$KEY_PATH" ]; then
        log_info "No SSH key found. Generating new SSH key..."
        sudo -u "$REAL_USER" ssh-keygen -t rsa -b 4096 -f "$KEY_PATH" -N ""
        log_info "SSH key created at $KEY_PATH"
        sudo chown "$REAL_USER:$REAL_USER" "$KEY_PATH" "$KEY_PATH.pub"
        sudo chmod 600 "$KEY_PATH"
        sudo chmod 644 "$KEY_PATH.pub"
        log_info "SSH key permissions set."
        log_info ""
    else
        log_info "SSH key already exists at $KEY_PATH"
    fi

    # Da auto roi, khong can nhap
    # # Nhập IP client
    # read -p "Enter client IP to deploy public key (e.g., 192.168.1.10): " client_ip
    # if [[ -z "$client_ip" ]]; then
    #     log_error "Client IP cannot be empty."
    #     return 1
    # fi

    read -p "Enter username on the client [default: ubuntu]: " client_user
    client_user=${client_user:-ubuntu}

    # Copy public key đến client
    # log_info "Deploying SSH public key to ${client_user}@${client_ip}..."
    # sudo -u "$REAL_USER" ssh-copy-id -i "$KEY_PATH.pub" "${client_user}@${client_ip}"

    # if [ $? -eq 0 ]; then
    #     log_info "SSH key deployed successfully. You can now connect without password:"
    #     echo "    ssh ${client_user}@${client_ip}"
    # else
    #     log_error "Failed to deploy SSH key. Check connection or credentials."
    # fi

    
    # Copy public key đến client
    deploysshkey --user "$client_user" --key "$KEY_PATH.pub" --inventory "./inventory.ini" --group "workers"
    log_info ""
    read -p "Press any key to continue..."
}
