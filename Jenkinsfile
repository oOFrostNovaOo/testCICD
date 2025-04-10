pipeline {
    agent any

    environment {
        REMOTE_USER = 'jenkinsdeploy'          // user SSH vào app server
        REMOTE_HOST = '192.168.11.21'         // IP máy App Server
        REMOTE_PATH = '/home/jenkinsdeploy/sourcecode'   // Thư mục nhận file
    }

    stages {
        stage('Clone Code') {
            steps {
                git 'https://github.com/oOFrostNovaOo/testCICD.git'
            }
        }

        stage('Deploy via SCP') {
            steps {
                sshagent(['847307a5-45c9-414e-a7a4-586781eef522']) { // ID của SSH Credential bạn đã tạo trong Jenkins
                    sh 'scp -o StrictHostKeyChecking=no index.html ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}'
                }
            }
        }
    }
}
