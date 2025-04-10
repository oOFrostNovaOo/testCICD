pipeline {
    agent any

    environment {
        REMOTE_USER = 'jenkinsdeploy'          // user SSH vào app server
        REMOTE_HOST = '192.168.11.21'         // IP máy App Server
        REMOTE_PATH = '/var/www/html'   // Thư mục nhận file
    }

    stages {
        stage('Start Pipeline') {
            steps {
                echo 'Bắt đầu chạy Jenkinsfile từ GitHub repository'
            }
        }
        
        stage('Clone Code') {
            steps {
                git branch: 'main', url: 'https://github.com/oOFrostNovaOo/testCICD.git'
            }
        }
        
        stage('Check HTML Syntax') {
            steps {
                echo 'Check syntax of HTML...'
                sh 'tidy -e index.html'
            }
        }

        stage('Deploy via SCP') {
            steps {
                sshagent(['847307a5-45c9-414e-a7a4-586781eef522']) { // ID của SSH Credential bạn đã tạo trong Jenkins
                    //backup old files
                    sh """
                ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST} '\
                    if [ -f ${REMOTE_PATH}/index.html ]; then \
                        cp ${REMOTE_PATH}/index.html ${REMOTE_PATH}/index.html.bak_$(date +%Y%m%d%H%M%S); \
                    else \
                        echo "No previous index.html to backup."; \
                    fi'
            """
                    // add mew files
                    sh 'scp -v -o StrictHostKeyChecking=no index.html ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}'
                    echo ' Ket thuc deploy'
                }
            }
        }
    }
}
