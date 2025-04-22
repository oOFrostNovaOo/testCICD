#!/bin/bash

function changeIP() {
    # Chạy dưới quyền root
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root"
        exit 1
    fi
    log_info "Changing IP address..."
    echo "Current IP address: $(hostname -I)"
    # Xác định interface mặc định
    iface=$(ip -o -4 route show to default | awk '{print $5}')
    [ -z "$iface" ] && { echo "Error: Cannot detect default interface"; exit 1; }
    log_warn "Default interface: $iface"

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
    IP="${ip_parts[0]}.${ip_parts[1]}.${ip_parts[2]}.$last_octet"
    echo "New IP address: $IP"


    # GATEWAY dùng gateway hiện tại làm mặc định
    suggested_gw=$(ip route | awk '/default/ {print $3}' | head -n 1)
    read -p "Default gateway [${suggested_gw}]: " GATEWAY
    GATEWAY=${GATEWAY:-$suggested_gw}

    # Suggest DNS server    
    read -p "Enter DNS server (default: 8.8.8.8): " DNS
    DNS=${DNS:-"8.8.8.8"}

    # Tìm file Netplan
    log_info "Searching for netplan config file..."
    netplan_file=$(find /etc/netplan -type f -name '*.yaml' | head -n1)
    [ -z "$netplan_file" ] && { log_error "Error: No netplan config found"; exit 1; }
    log_info "Netplan file found: $netplan_file"

    log_warn "[INFO] iface=$iface, new_ip=$IP, gateway=$GATEWAY, dns=$DNS"

    # Ghi cấu hình mới
    cat > "$netplan_file" <<EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    $iface:
      addresses:
        - $IP/24
      routes:
        - to: 0.0.0.0/0
          via: $GATEWAY
      nameservers:
        addresses:
$(printf '          - %s\n' "${DNS[@]}")
EOF

    netplan apply
    log_info "[OK] IP changed to $IP on $iface"
}
