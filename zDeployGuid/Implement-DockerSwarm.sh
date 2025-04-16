#!/bin/bash

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

usermod -aG docker $USER

echo "Docker Swarm, Terraform, and Ansible have been successfully installed."