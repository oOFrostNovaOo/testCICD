#!/bin/bash
# =========================================
# Author: Minh Nguyen
# Description: Bash script to generate Ansible inventory and host_vars
# =========================================

if [ -z "$1" ]; then
  echo "❌ Missing config file. Usage: $0 <config_file.env>"
  exit 1
fi

CONFIG_FILE="$1"

# Kiểm tra file tồn tại không
if [ ! -f "$CONFIG_FILE" ]; then
  echo "❌ Config file '$CONFIG_FILE' not found!"
  exit 1
fi

# Load config file
source "$CONFIG_FILE" #config.env

# Config IP range
# BASE_IP="192.168.11"
# LEADER=11
# START=12
# END=13
# GATEWAY="192.168.11.2"
# SUBNET_MASK=24
# DNS="[8.8.8.8, 1.1.1.1]"

echo "Base IP: $BASE_IP"
echo "Range: $START" 
echo "to $END"
echo "Gateway: $GATEWAY"
echo "Subnet: $SUBNET_MASK"
echo "DNS: $DNS"

# Tạo thư mục nếu chưa có
mkdir -p host_vars

# Xóa inventory cũ nếu có
echo "[leaders]" > inventory.ini

# Tạo host_vars cho leader
HOSTNAME="leader1"
IP="${BASE_IP}.${LEADER}"
cat <<EOF > host_vars/${HOSTNAME}.yml
ip_address: $IP
subnet_mask: $SUBNET_MASK
gateway: $GATEWAY
dns_servers: $DNS
EOF
echo "$HOSTNAME ansible_host=$IP" >> inventory.ini
echo "Created leaders $HOSTNAME with IP $IP"

# Lặp tạo host_vars và inventory
echo "" >> inventory.ini
echo "[workers]" >> inventory.ini
i=1
for OCTET in $(seq $START $END); do
  HOSTNAME="worker$i"
  IP="${BASE_IP}.${OCTET}"

  # Ghi inventory
  echo "$HOSTNAME ansible_host=$IP  ansible_ssh_private_key_file=~/.ssh/id_rsa" >> inventory.ini

  # Ghi host_vars
  cat <<EOF > host_vars/${HOSTNAME}.yml
ip_address: $IP
subnet_mask: $SUBNET_MASK
gateway: $GATEWAY
dns_servers: $DNS
EOF

  echo "Created $HOSTNAME with IP $IP"
  ((i++))
done

echo "" >> inventory.ini
echo "[all:vars]" >> inventory.ini
echo "ansible_user=ubuntu" >> inventory.ini  
echo "ansible_ssh_private_key_file=~/.ssh/id_rsa" >> inventory.ini
echo "ansible_ssh_common_args='-o ConnectTimeout=5 -o StrictHostKeyChecking=no'" >> inventory.ini

echo "✅ Done! Generated host_vars + inventory.ini"
