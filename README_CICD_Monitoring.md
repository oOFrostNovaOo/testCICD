
# CI/CD & Monitoring Project with Jenkins, Prometheus, Grafana

## 🖥️ Hạ tầng

- **vm01**: `192.168.11.11` – Cài Jenkins, Prometheus, Node Exporter, Local Registry
- **vm02**: `192.168.11.12` – Cài Grafana, Node Exporter
- Docker Swarm đã được cấu hình sẵn, overlay network tên `cicd_stack` đã tạo.

---

## 🗂️ Cấu trúc thư mục

```
JENS+PROM+GRAF/
├── grafana/
│   └── docker-compose.yml
├── jenkins/
│   ├── docker-compose.yml
│   └── dockerfile
├── node-exporter/
│   └── node-exporter.yml
├── prometheus/
│   ├── docker-compose.yml
│   └── prometheus.yml
├── registry/
│   └── docker-compose.yml
└── TestCICD/
    ├── ansible/
    │   ├── deploy.yml
    │   └── inventory.ini
    ├── JenkinsFiles/
    │   ├── Jenkinsfile
    │   └── jenkinsfile_copycodetovm
    └── SourceCode/
        └── web-sc/
            ├── index.html
            └── Dockerfile
```

---

## 🧱 Jenkins Dockerfile

```dockerfile
FROM jenkins/jenkins:lts
USER root
RUN apt-get update &&     apt-get install -y apt-transport-https ca-certificates curl gnupg software-properties-common gnupg2 lsb-release &&     curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg &&     echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list &&     apt-get update &&     apt-get install -y docker-ce-cli python3 python3-pip unzip wget openssh-client &&     pip3 install ansible --break-system-packages &&     wget https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip &&     unzip terraform_1.6.6_linux_amd64.zip -d /usr/local/bin &&     rm terraform_1.6.6_linux_amd64.zip &&     ssh-keygen -t rsa -b 4096 -N "" -f /var/jenkins_home/.ssh/id_rsa &&     cat /var/jenkins_home/.ssh/id_rsa.pub > /var/jenkins_home/.ssh/authorized_keys &&     chmod 700 /var/jenkins_home/.ssh &&     chmod 600 /var/jenkins_home/.ssh/id_rsa &&     chmod 644 /var/jenkins_home/.ssh/id_rsa.pub /var/jenkins_home/.ssh/authorized_keys &&     apt-get clean && rm -rf /var/lib/apt/lists/*
USER jenkins
```

---

## 🔧 Prometheus config

**prometheus.yml**:

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'node_exporter'
    static_configs:
      - targets: ['192.168.11.11:9100', '192.168.11.12:9100']

  - job_name: 'jenkins'
    metrics_path: /prometheus
    static_configs:
      - targets: ['192.168.11.11:8080']

  - job_name: 'jenkins-exporter'
    static_configs:
      - targets: ['jenkins:9100']

  - job_name: 'grafana'
    static_configs:
      - targets: ['grafana:3000']
```

---

## 📦 Local Docker Registry (vm01)

**registry/docker-compose.yml**:

```yaml
version: "3.8"
services:
  registry:
    image: registry:2
    ports:
      - "5000:5000"
    networks:
      - cicd_stack

networks:
  cicd_stack:
    external: true
```

---

## 🚀 CI/CD Jenkinsfile (ví dụ)

```groovy
pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/your/repo.git'
            }
        }
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t 192.168.11.11:5000/webapp:latest ./SourceCode/web-sc'
            }
        }
        stage('Push to Registry') {
            steps {
                sh 'docker push 192.168.11.11:5000/webapp:latest'
            }
        }
        stage('Deploy via Ansible') {
            steps {
                sh 'ansible-playbook -i ansible/inventory.ini ansible/deploy.yml'
            }
        }
    }
}
```

---

## ✅ Triển khai toàn hệ thống

1. Khởi động Docker Swarm:  
   ```bash
   docker swarm init
   docker network create -d overlay cicd_stack
   ```

2. Build Jenkins image:
   ```bash
   cd jenkins/
   docker build -t myjenkins:v2 .
   ```

3. Deploy tất cả các dịch vụ:
   ```bash
   docker stack deploy -c docker-compose.yml cicd_stack
   ```

---

## 📥 Copy thư mục từ Windows sang Ubuntu (WSL/VM)

```powershell
scp -r C:\path\to\folder user@192.168.11.11:/home/ubuntu/project/
```

---

## ✅ Note

- Node Exporter phải chạy **trên cả 2 VM**
- Jenkins cần plugin: `Prometheus Metrics Plugin`
- Cần mở port cho Prometheus (9090), Grafana (3000), Registry (5000)

