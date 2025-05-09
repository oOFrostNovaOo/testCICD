#!/bin/bash

function implement_Docker_swarm() {
    # Lấy IP từ nhóm [leader] trong inventory
    leader_ip=$(ansible leaders -i inventory.ini -m setup -a 'filter=ansible_default_ipv4' \
    | grep '"address"' | head -n1 | awk -F'"' '{print $4}')
    
    # Install Docker trên tất cả các node
    echo "📦 Installing Docker..."
    ansible-playbook -i inventory.ini playbooks/install_docker.yml

    echo "👑 Initializing Swarm (Leader)..."
    ansible-playbook -i inventory.ini playbooks/init_swarm.yml

    echo "📤 Extracting token and saving to swarm_token.yml..."
    token=$(cat /tmp/swarm_token.txt)
    echo "swarm_token: \"$token\"" > playbooks/swarm_token.yml
    echo "leader_ip: \"$leader_ip\"" >> playbooks/swarm_token.yml

    echo "----------------"
    echo "🔗 Joining Workers to Swarm..."
    ansible-playbook -i inventory.ini playbooks/join_swarm.yml
    echo "✅ Docker Swarm setup completed."
    read -p "Press any key to continue..."
    echo "-----------------------------------------------"
}