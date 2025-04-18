#!/bin/bash

function changeIP() {
    # Chạy dưới quyền root
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root"
        exit 1
    fi

    # Xác định interface mặc định
    iface=$(ip -o -4 route show to default | awk '{print $5}')
    [ -z "$iface" ] && { echo "Error: Cannot detect default interface"; exit 1; }

    # Lấy hostname hiện tại
    host=$(hostname -s)

    env_file="./env.json"
    [ ! -f "$env_file" ] && { echo "Error: env.json not found"; exit 1; }

    # Lấy IP mới từ env.json (default_ip)
    new_ip=$(jq -r --arg name "$host" '
        (.leader_nodes[]   | select(.name == $name) | .default_ip)
        // (.worker_node_list[] | select(.name == $name) | .default_ip)
    ' "$env_file")
    [ -z "$new_ip" ] && { echo "Error: No matching default_ip for $host"; exit 1; }

    # Lấy gateway và DNS từ env.json
    gateway=$(jq -r '.gateway' "$env_file")
    dns_servers=$(jq -r '.dns | join(", ")' "$env_file")

    # Tìm file Netplan
    netplan_file=$(find /etc/netplan -type f -name '*.yaml' | head -n1)
    [ -z "$netplan_file" ] && { echo "Error: No netplan config found"; exit 1; }

    echo "[INFO] iface=$iface, new_ip=$new_ip, gateway=$gateway, dns=[$dns_servers]"

    # Ghi cấu hình mới
    cat > "$netplan_file" <<EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    $iface:
      addresses:
        - $new_ip/24
      gateway4: $gateway
      nameservers:
        addresses: [ $dns_servers ]
EOF

    netplan apply
    echo "[OK] IP changed to $new_ip on $iface"
}
