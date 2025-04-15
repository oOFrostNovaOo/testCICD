# CI/CD với Jenkins + Docker Swarm + Ansible

## 📁 Cấu trúc thư mục `testCICD/`

```
testCICD/
├── Jenkinsfile
├── Dockerfile
├── docker-compose.yml
├── web-sc/
│   └── index.html
└── ansible/
    ├── inventory.ini
    └── deploy.yml
```

---

## 🚀 CI/CD Pipeline dùng Jenkins + Docker Swarm + Ansible

### ✅ 1. Tạo Docker Registry nội bộ

```bash
docker run -d -p 5000:5000 --restart=always --name registry registry:2
```

---

### ✅ 2. Tạo Jenkins Image (Dockerfile.jenkins)

```Dockerfile
FROM jenkins/jenkins:lts

USER root

RUN apt-get update && \
    apt-get install -y apt-transport-https ca-certificates curl gnupg curl software-properties-common gnupg2 lsb-release && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y docker-ce-cli python3 python3-pip unzip wget && \
    pip3 install ansible --break-system-packages && \
    wget https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip && \
    unzip terraform_1.6.6_linux_amd64.zip -d /usr/local/bin && \
    rm terraform_1.6.6_linux_amd64.zip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER jenkins
```

Build image:
```bash
docker build -t img-jenk-ans-ter -f Dockerfile.jenkins .
```

---

### ✅ 3. Chạy Jenkins container trên Docker Swarm

```yaml
version: '3.8'

services:
  jenkins:
    image: img-jenk-ans-ter:latest
    ports:
      - "8080:8080"
      - "50000:50000"
    user: root
    volumes:
      - jenkins_data:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
      - /etc/timezone:/etc/timezone:ro
      - /etc/localtime:/etc/localtime:ro
    environment:
      - DOCKER_HOST=unix:///var/run/docker.sock
    networks:
      - cicd
    deploy:
      placement:
        constraints:
          - node.hostname == app-vm1
      restart_policy:
        condition: any

volumes:
  jenkins_data:

networks:
  cicd:
    external: false
```

```bash
docker swarm init
docker stack deploy -c docker-compose.yml jenkins_stack
docker stack services jenkins_stack
```

---

### ✅ 4. SSH không mật khẩu giữa Jenkins và app-server

```bash
ssh-keygen -t rsa -b 4096
ssh-copy-id -i ~/.ssh/id_rsa.pub ubuntu@192.168.11.21
```

---

### ✅ 5. Jenkinsfile – CI/CD pipeline

####groovy
pipeline {
  agent any

  stages {
    stage('Checkout') {
      steps {
        cleanWs()
        git branch: 'main', url: 'https://github.com/oOFrostNovaOo/testCICD.git'
      }
    }

    stage('Build and Push Docker Image') {
      steps {
        sh '''
          docker build -t hello-nginx:latest .
          docker tag hello-nginx:latest 192.168.11.11:5000/hello-nginx:latest
          docker push 192.168.11.11:5000/hello-nginx:latest
        '''
      }
    }

    stage('Deploy to Swarm') {
      steps {
        sh '''
          docker service rm hello_service || true
          docker service create --name hello_service --replicas 1 --publish 8081:80 \
            --with-registry-auth \
            --constraint "node.labels.role == web" \
            --mount type=bind,source=/home/ubuntu/sourcecode,target=/usr/share/nginx/html \
            192.168.11.11:5000/hello-nginx:latest
        '''
      }
    }

    stage('Deploy with Ansible') {
      steps {
        sh 'ansible-playbook -i ansible/inventory.ini ansible/deploy.yml'
      }
    }
  }
}
############################

---

### ✅ 6. index.html (web-sc/index.html)

```html
<!DOCTYPE html>
<html>
<head>
  <title>Hello from Jenkins CI/CD!</title>
</head>
<body>
  <h1>Hello World - Deployed via Jenkins, Docker Swarm & Ansible!</h1>
</body>
</html>
```

---

### ✅ 7. Ansible inventory và playbook

📄 `ansible/inventory.ini`
```ini
[web]
worker-node-1 ansible_host=192.168.11.21 ansible_user=ubuntu
```

📄 `ansible/deploy.yml`
```yaml
- name: Triển khai ứng dụng Nginx
  hosts: web
  become: true
  tasks:
    - name: Tạo thư mục /home/ubuntu/sourcecode nếu chưa có
      file:
        path: /home/ubuntu/sourcecode
        state: directory
        owner: ubuntu
        group: ubuntu
        mode: '0755'

    - name: Copy file index.html
      copy:
        src: ../web-sc/index.html
        dest: /home/ubuntu/sourcecode/index.html
```

---

### ✅ 8. Gán label cho node (VM2)

```bash
docker node ls
docker node update --label-add role=web <node-id>
```

---

### ✅ 9. Kiểm tra image trên local registry

```bash
curl http://192.168.11.11:5000/v2/hello-nginx/tags/list
```

---

✅ Hệ thống CI/CD của bạn giờ đã hoàn thiện và chạy hoàn toàn bằng Docker Swarm, Jenkins, Ansible và GitHub.
