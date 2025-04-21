#!/bin/bash

function install_terraform() {
    if command -v terraform &> /dev/null; then
        echo "✅ Terraform is already installed."
    else
        installing_terraform
    fi
}
function installing_terraform() {
    # echo "📦 Installing Terraform..."
    # sudo apt update
    # sudo apt install -y wget unzip gnupg
    # wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor > hashicorp.gpg
    # sudo install -o root -g root -m 644 hashicorp.gpg /etc/apt/trusted.gpg.d/
    # sudo sh -c 'echo "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/hashicorp.list'
    # sudo apt update
    # sudo apt install -y terraform
    # echo "✅ Terraform installed."
    # read -p "Press any key to continue..."

    echo "📦 Installing Docker..."
    ansible-playbook -i inventory.ini playbooks/install_terraform.yml
}


