pipeline {
  agent any

  stages {
    stage('Checkout') {
      steps {
        git 'https://github.com/oOFrostNovaOo/testCICD.git'
      }
    }

    stage('Build Docker Image') {
      steps {
        sh 'docker build -t hello-nginx:latest .'
      }
    }

    stage('Deploy to Swarm') {
      steps {
        sh 'docker service update --image hello-nginx:latest hello_service || docker service create --name hello_service -p 8081:80 hello-nginx:latest'
      }
    }

    stage('Deploy with Ansible') {
      steps {
        sh 'ansible-playbook -i ansible/inventory.ini ansible/deploy.yml'
      }
    }
  }
}
