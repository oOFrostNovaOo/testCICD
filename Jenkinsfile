pipeline {
  agent any

  stages {
    stage('Clone') {
      steps {
        git 'https://github.com/youruser/yourrepo.git'
      }
    }

    stage('Build') {
      steps {
        sh 'echo "No build step needed for now"'
      }
    }

    stage('Test') {
      steps {
        sh 'pytest tests/'  // nếu có
      }
    }

    stage('Deploy') {
      steps {
        sshagent(['your-ssh-credential-id']) {
          sh 'scp -r . user@app-server:/opt/app && ssh user@app-server "systemctl restart app.service"'
        }
      }
    }
  }
}
