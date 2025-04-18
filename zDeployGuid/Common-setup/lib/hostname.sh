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

    # Lấy địa chỉ IP hiện tại của máy
    current_ip=$(hostname -I | awk '{print $1}')
    
    # Kiểm tra nếu địa chỉ IP hiện tại khớp với bất kỳ IP nào trong env.json
    # Đọc file env.json và tìm hostname tương ứng với current_ip
    new_hostname=$(jq -r --arg ip "$current_ip" '
        .leader_nodes[] | select(.default_ip == $ip) | .name
        ' env.json)

    # Nếu không tìm thấy, kiểm tra trong danh sách worker node
    if [ -z "$new_hostname" ]; then
        new_hostname=$(jq -r --arg ip "$current_ip" '
            .worker_node_list[] | select(.default_ip == $ip) | .name
            ' env.json)
    fi

    # Nếu vẫn không tìm thấy hostname, thông báo lỗi
    if [ -z "$new_hostname" ]; then
        echo "Error: No matching hostname found for IP $current_ip"
        exit 1
    fi

    # Thay đổi hostname
    sudo hostnamectl set-hostname "$new_hostname"
    log_info "Hostname changed to $new_hostname"
    echo "Press any key to continue..."
    read -n 1
}

# Giả sử hàm log_info đã được định nghĩa sẵn trong hệ thống
log_info() {
    echo "[INFO] $1"
}