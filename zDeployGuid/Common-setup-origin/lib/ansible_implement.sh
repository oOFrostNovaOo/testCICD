function ansible_change_IP() {
    # Load config file
    read -p "Enter config file (default: config.env): " env_file
    ENVFile=${env_file:-config.env}
    if [ ! -f "$ENVFile" ]; then
        log_error "Config file '$ENVFile' not found!"
        exit 1
    fi
    log_info "Loading config from $ENVFile..."            
    bash ./lib/generate_hosts.sh $ENVFile
    log_info "Changing IP address..."

    #kiem tra ton tai cua file vault.yml
    if [ ! -f ./vault.yml ]; then
        echo "File vault.yml not found. Please create it first."
        ansible-vault create ./vault.yml
    fi
    #kiem tra ton tai cua file inventory_pre.ini
    if [ ! -f ./inventory_pre.ini ]; then
        echo "File inventory_pre.ini not found. Please create it first."
        exit 1
    fi
    # check if sshpass is installed
    if ! command -v sshpass &> /dev/null; then
        echo "sshpass could not be found, installing..."
        sudo apt update
        sudo apt install -y sshpass
    fi
    # Run Ansible tp change IP
    ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory_pre.ini ./playbooks/setup_ip_clients.yml  --ask-pass  --ask-vault-pass  
}

function ansible_change_hostname_timezone() {
    # Ansible changes hostname
    ansible-playbook -i inventory.ini ./playbooks/set_hostname_timezone.yml
}

function deploy_sshKey() { 
    INVENTORY="inventory.ini"
    KEY="$HOME/.ssh/id_rsa"
    PASS="qwe123"   # ← đổi thành mật khẩu thực tế nếu khác
    USER="ubuntu"   # ← hoặc lấy từ ansible_user nếu muốn

    read -p "Enter SSH Username (deault: $USER): " -s user
    USER=${user:-$USER}  # Nếu người dùng không nhập, dùng giá trị cũ
    read -p "Enter SSH Password (default: $PASS): " -s pass
    PASS=${pass:-$PASS}  # Nếu người dùng không nhập, dùng giá trị cũ

    # B1: Tạo SSH key nếu chưa có
    if [ ! -f "$KEY" ]; then
    echo "[+] Generating SSH key..."
    ssh-keygen -t rsa -b 2048 -f "$KEY" -N ""
    else
    echo "[i] SSH key already exists at $KEY"
    fi

    # B2: Trích IP từ inventory
    IPS=($(grep -E 'ansible_host=' "$INVENTORY" | awk '{print $2}' | sed -E 's/.*ansible_host=//'))

    # B3: Copy SSH key
    for ip in "${IPS[@]}"; do
    echo -e "\n[+] Copying key to $ip"
    echo "$PASS ssh-copy-id -o StrictHostKeyChecking=no $USER@$ip"
    sshpass -p "$PASS" ssh-copy-id -o StrictHostKeyChecking=no "$USER@$ip"
    done

    # B4: Test kết nối
    for ip in "${IPS[@]}"; do
    echo -e "\n[+] Testing SSH connection to $ip"
    ssh -o PasswordAuthentication=no -o BatchMode=yes "$USER@$ip" 'echo "[✓] SSH OK!"' || echo "[✗] Failed to connect"
    done
}