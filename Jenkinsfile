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
          # Build image
          docker build -t hello-nginx:latest .

          # Tag lại image với địa chỉ local registry
          docker tag hello-nginx:latest 192.168.11.11:5000/hello-nginx:latest

          # Push image lên local registry
          docker push 192.168.11.11:5000/hello-nginx:latest
        '''
      }
    }

    stage('Deploy with Ansible') {
      steps {
        sh 'ansible-playbook -i ansible/inventory.ini ansible/deploy.yml'
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

    
  }
}
