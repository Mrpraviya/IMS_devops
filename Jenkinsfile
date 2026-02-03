 pipeline {
    agent any
    
    environment {
        DEPLOY_SERVER = '54.144.116.87'
        DEPLOY_USER = 'ubuntu'
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo '🔄 Pulling latest code from GitHub...'
                checkout scm
            }
        }
        
stage('Deploy to Production') {
    steps {
        sh '''
        ssh -o StrictHostKeyChecking=no ubuntu@54.144.116.87 "
            set -e
            cd ~/IMS_devops
            git pull origin main
            docker compose pull
            docker compose up -d --build
        "
        '''
    }
}


        stage('Verify Deployment') {
            steps {
                echo '🔍 Verifying deployment...'
                sh '''
                    ssh -o StrictHostKeyChecking=no ${DEPLOY_USER}@${DEPLOY_SERVER} << 'ENDSSH'
                        curl -f http://localhost:5000/api/products
                        curl -f http://localhost/api/products
                        echo "✅ Deployment verified!"
ENDSSH
                '''
            }
        }
    }
    
    post {
        success {
            echo '✅ Pipeline completed successfully!'
        }
        failure {
            echo '❌ Pipeline failed!'
        }
    }
}
