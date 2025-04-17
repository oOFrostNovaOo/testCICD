#!/bin/bash

   """
    Initializes a Docker Swarm cluster using Ansible playbooks.

    This function retrieves the IP address of the leader node from the inventory,
    installs Docker on all nodes, initializes the Swarm on the leader node, extracts
    the join token, and saves it along with the leader IP to a YAML file. Finally,
    it joins the worker nodes to the Swarm using the extracted token.

    Steps:
    1. Retrieve leader node IP address  from the 'leader' group in the inventory.
    2. Install Docker on all nodes using the 'install_docker.yml' playbook.
    3. Initialize the Swarm on the leader node using the 'init_swarm.yml' playbook.
    4. Extract the Swarm join token and save it to 'swarm_token.yml'.
    5. Join worker nodes to the Swarm using the 'join_swarm.yml' playbook.
    """
function implement_Docker_swarm() {
    # Lấy IP từ nhóm [leader] trong inventory
    leader_ip=$(ansible leader -i inventory.ini -m setup -a 'filter=ansible_default_ipv4.address' | grep ansible_default_ipv4.address | awk '{print $2}')
    echo "Leader IP: $leader_ip"

    # Install Docker trên tất cả các node
    echo "📦 Installing Docker..."
    ansible-playbook -i inventory.ini playbooks/install_docker.yml

    echo "👑 Initializing Swarm (Leader)..."
    ansible-playbook -i inventory.ini playbooks/init_swarm.yml

    echo "📤 Extracting token and saving to swarm_token.yml..."
    token=$(cat swarm_token.txt)
    echo "swarm_token: $token" > playbooks/swarm_token.yml
    echo "leader_ip: 192.168.1.10" >> playbooks/swarm_token.yml

    echo "🔗 Joining Workers to Swarm..."
    ansible-playbook -i inventory.ini playbooks/join_swarm.yml
}
