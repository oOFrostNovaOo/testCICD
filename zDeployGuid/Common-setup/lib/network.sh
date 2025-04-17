#!/bin/bash

# ----------------------------------------
# Function: Change IP address (Ubuntu netplan)
# ----------------------------------------
function changeIP() {
    # Check NIC name
    #default_iface=$(ip route | awk '/default/ {print $5}' | head -n 1)
    default_iface=$(ip -o -4 route show to default | awk '{print $5}')
    read -p "Detected interface is '$default_iface'. Press Enter to accept or enter a different name: " iface
    iface=${iface:-$default_iface}
        
    #Type of IP address
    # Lấy IP hiện tại (ví dụ: 192.168.11.128)
    current_ip=$(hostname -I | awk '{print $1}')
    
    # Tách các phần của IP hiện tại
    IFS='.' read -ra ip_parts <<< "$current_ip"
    
    # Giữ lại ba octet đầu, chỉ yêu cầu người dùng nhập số cho octet cuối
    new_octet=${ip_parts[3]}
    read -p "Current IP is $current_ip. Enter new last octet (current: $new_octet): " last_octet
    last_octet=${last_octet:-$new_octet}  # Nếu người dùng không nhập, dùng giá trị cũ
    
    # Tạo IP mới
    new_ip="${ip_parts[0]}.${ip_parts[1]}.${ip_parts[2]}.$last_octet"
    echo "New IP address: $new_ip"


    # GATEWAY dùng gateway hiện tại làm mặc định
    suggested_gw=$(ip route | awk '/default/ {print $3}' | head -n 1)
    read -p "Default gateway [${suggested_gw}]: " gateway
    gateway=${gateway:-$suggested_gw}

    # Suggest DNS server    
    read -p "Enter DNS server (default: 8.8.8.8): " dns
    dns=${dns:-"8.8.8.8"}

    # Find netplan config file
    NETPLAN_FILE=$(find /etc/netplan -name "*.yaml" | head -n 1)

    if [ -z "$NETPLAN_FILE" ]; then
        log_error "No netplan config found."
        exit 1
    fi

    log_info "Updating Netplan config: $NETPLAN_FILE"

    cat > $NETPLAN_FILE <<EOL
network:
  version: 2
  renderer: networkd
  ethernets:
    $iface:
      addresses:
        - $new_ip/24
      gateway4: $gateway
      nameservers:
        addresses:
          - $dns
EOL

    sudo netplan apply
}