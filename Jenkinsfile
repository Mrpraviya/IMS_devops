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

        stage('Cleanup Docker') {
            steps {
                sh '''
                ssh -o StrictHostKeyChecking=no ${DEPLOY_USER}@${DEPLOY_SERVER} \
                "docker system prune -a -f"
                '''
            }
        }

        stage('Deploy to Production') {
            steps {
                sh '''
                ssh -o StrictHostKeyChecking=no ${DEPLOY_USER}@${DEPLOY_SERVER} "
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
                ssh -o StrictHostKeyChecking=no ${DEPLOY_USER}@${DEPLOY_SERVER} "
                    curl -f http://localhost:5000/api/products
                    echo '✅ Deployment verified!'
                "
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
