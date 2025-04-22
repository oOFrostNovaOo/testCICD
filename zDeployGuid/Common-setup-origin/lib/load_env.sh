#!/bin/bash

# Check và cài jq nếu chưa có
function install_jq() {
    #check run as root
    if [ "$EUID" -ne 0 ]; then
        log_error "[ERROR] Please run as root to install jq"
        exit 1
    fi
    #check if jq is installed to install jq
    if ! command -v jq >/dev/null 2>&1; then
        echo "[INFO] jq not found. Installing..."
        apt update && apt install -y jq
        if [ $? -ne 0 ]; then
            echo "[ERROR] Failed to install jq. Exiting..."
            exit 1
        fi
    fi
}

# Gán các biến toàn cục từ env.json
function load_env() {
    ENV_FILE="./env.json"
    
    install_jq

    if [ ! -f "$ENV_FILE" ]; then
        echo "❌ env.json not found!"
        exit 1
    fi

    # IP hiện tại
    local ip=$(hostname -I | awk '{print $1}')
    
    declare -g DEFAULT_IP="$ip"
    # IP moi
    # Tìm hostname trong leader_nodes
    declare -g IP=$(jq -r --arg ip "$ip" '.leader_nodes_list[] | select(.default_ip == $ip) | .ip' "$ENV_FILE")
    # Nếu không có, tìm trong worker_node_list
    if [ -z "$IP" ]; then
        IP=$(jq -r --arg ip "$ip" '.worker_node_list[] | select(.default_ip == $ip) | .ip' "$ENV_FILE")
    fi
    # Nếu không có IP nào, thoát
    if [ -z "$IP" ]; then
        echo "❌ No matching IP found for $ip"
        exit 1
    fi

    # Gateway & DNS mặc định
    #declare -g DNS=$(jq -r '.dns // ["8.8.8.8"] | map("- \(. )") | .[]' "$ENV_FILE")
    declare -g DNS=($(jq -r '.network.dns // ["192.168.1.1"] | .[]' "$ENV_FILE"))

    suggested_gw=$(jq -r '.network.gateway // empty' "$ENV_FILE")
    if [ -z "$suggested_gw" ]; then
        suggested_gw=$(ip route | awk '/default/ {print $3}' | head -n 1)
    fi
    declare -g GATEWAY="$suggested_gw"
   
    # Tìm hostname trong leader_nodes
    local hostname=$(jq -r --arg ip "$ip" '.leader_nodes[] | select(.default_ip == $ip) | .name' "$ENV_FILE")

    # Nếu không có, tìm trong worker_node_list
    if [ -z "$hostname" ]; then
        hostname=$(jq -r --arg ip "$ip" '.worker_node_list[] | select(.default_ip == $ip) | .name' "$ENV_FILE")
    fi
    # Nếu không có hostname nào, thoát
    if [ -z "$hostname" ]; then
        echo "❌ No matching hostname found for IP $ip"
        exit 1
    fi
    declare -g HOSTNAME="$hostname"


    # Tim current_user trong env.json
    export REAL_USER=$(jq -r '.current_user' "$ENV_FILE")
    export INFRA_STACK=$(jq -r '.infrastructure_stack_name' "$ENV_FILE")
    export APP_STACK=$(jq -r '.application_stack_name' "$ENV_FILE")
    export client_user=$(jq -r '.client_user' "$ENV_FILE")
    # Tạo mảng từ các key trong worker_node_list
    #mapfile -t NAME_WORKER_LIST < <(jq -r '.worker_node_list[] | .name' "$ENV_FILE")
    mapfile -t IP_WORKER_LIST < <(jq -r '.worker_node_list[] | .ip' "$ENV_FILE")
    
    # In ket qua ra man hình
    echo "✅ ENV loaded:"
    echo "HOSTNAME=$HOSTNAME"
    echo "IP=$IP"
    echo "DEFAULT_IP=$DEFAULT_IP"
    echo "GATEWAY=$GATEWAY"
    echo "DNS=${DNS[@]}"
}


