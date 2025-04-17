#!/bin/bash
function install_ansible() {
    if command -v ansible &> /dev/null; then
        echo "✅ Ansible is already installed."
    else
        echo "📦 Installing Ansible..."
    # Prints a message indicating that Ansible is being installed, then installs
    # Ansible, then prints a success message with the installed version.
    # Waits for the user to press a key before continuing.
        sudo apt install -y ansible
        echo "✅ Ansible installed."
        local version
        version=$(ansible --version | head -n 1 | awk '{print $2}')
        echo "Ansible version: $version"
        read -p "Press any key to continue..."
    fi
}
