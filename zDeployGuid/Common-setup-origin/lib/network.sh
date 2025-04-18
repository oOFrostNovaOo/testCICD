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

    # Lấy gateway và DNS từ env.json

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
