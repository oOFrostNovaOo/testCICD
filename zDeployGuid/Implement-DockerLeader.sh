#!/bin/bash

# Kiểm tra xem IP remote node có được nhập không
if [ -z "$1" ]; then
  echo "Vui lòng nhập IP của remote node."
  exit 1
fi

# Manager info
MANAGER_IP="192.168.1.201"          # IP của manager (có thể thay đổi nếu cần)
SSH_USER="ubuntu"                   # user để SSH vào node remote
NODE_IP="$1"                         # IP của remote node được nhập từ đối số

# Update and upgrade the system
sudo apt update && sudo apt upgrade -y

# Install Terraform
sudo apt install -y wget unzip
TERRAFORM_VERSION="1.5.7" # Replace with the desired version
wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
sudo mv terraform /usr/local/bin/
rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Verify Terraform installation
terraform --version

# Install Ansible
sudo apt update
sudo apt install -y ansible

# Verify Ansible installation
ansible --version

# Install Docker
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Enable and start Docker service
sudo systemctl enable docker
sudo systemctl start docker

sudo usermod -aG docker $USER

sudo docker swarm init

# Verify Docker installation
docker --version
docker swarm --version
docker-compose --version    

echo "Docker Swarm, Terraform, and Ansible have been successfully installed."

# Lấy token từ manager (giả sử bạn đang chạy script này trên chính manager)
SWARM_TOKEN=$(docker swarm join-token -q worker)

# SSH vào node remote và join swarm
echo "Đang join node ${NODE_IP} vào swarm với manager ${MANAGER_IP}..."
ssh ${SSH_USER}@${NODE_IP} "docker swarm join --token ${SWARM_TOKEN} ${MANAGER_IP}:2377"


### Cấu hình Docker với insecure registry
# Địa chỉ registry không an toàn (insecure registry)
REGISTRY="192.168.1.201:5000"
DAEMON_FILE="/etc/docker/daemon.json"

echo "==> Adding $REGISTRY to insecure-registries..."

# Backup file cấu hình cũ nếu có
if [ -f "$DAEMON_FILE" ]; then
    sudo cp "$DAEMON_FILE" "${DAEMON_FILE}.bak_$(date +%s)"
fi

# Tạo file daemon.json nếu chưa tồn tại
if [ ! -f "$DAEMON_FILE" ]; then
    echo -e "{\n  \"insecure-registries\": [\"$REGISTRY\"]\n}" | sudo tee $DAEMON_FILE
else
    # Kiểm tra nếu đã có "insecure-registries" thì chèn thêm nếu chưa có registry này
    if grep -q "insecure-registries" $DAEMON_FILE; then
        if grep -q "$REGISTRY" $DAEMON_FILE; then
            echo "✔️  Registry $REGISTRY đã có trong cấu hình."
        else
            sudo sed -i "s/\[.*\]/[\"$REGISTRY\"]/" $DAEMON_FILE
            echo "✅ Đã thêm $REGISTRY vào danh sách insecure-registries."
        fi
    else
        # Thêm mới dòng insecure-registries nếu chưa có
        sudo sed -i "1s|{|{\n  \"insecure-registries\": [\"$REGISTRY\"],|" $DAEMON_FILE
        echo "✅ Đã thêm insecure-registries mới."
    fi
fi

# Khởi động lại Docker
echo "🔄 Restarting Docker service..."
sudo systemctl daemon-reexec
sudo systemctl restart docker

echo "✅ Docker đã được cấu hình với insecure registry: $REGISTRY"

