pipeline {
  agent any

  stages {
    stage('Checkout') {
      steps {
        cleanWs()
        git branch: 'main', url: 'https://github.com/oOFrostNovaOo/testCICD.git'
      }
    }

    stage('Build Docker Image') {
      steps {
        sh 'docker build -t hello-nginx:latest .'
      }
    }

    stage('Deploy to Swarm') {
      steps {
        sh """
          docker service inspect hello_service >/dev/null 2>&1 && \
          docker service update --image hello-nginx:latest hello_service || \
          docker service create --name hello_service -p 8081:80 \
            --constraint 'node.labels.role == web' \
            --mount type=bind,source=/home/ubuntu/sourcecode,target=/usr/share/nginx/html \
            hello-nginx:latest
        """
      }
    }

    stage('Deploy with Ansible') {
      steps {
        sh 'ansible-playbook -i ansible/inventory.ini ansible/deploy.yml'
      }
    }
  }
}
