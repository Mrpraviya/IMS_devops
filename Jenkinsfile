 pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                echo '🔄 Pulling latest code from GitHub...'
                checkout scm
            }
        }

        stage('Build') {
            steps {
                echo '🏗️ Building Docker images...'
                sh 'docker compose build'
            }
        }

        stage('Deploy') {
            steps {
                echo '🚀 Deploying application...'
                sh 'docker compose up -d'
            }
        }

        stage('Verify') {
            steps {
                echo '🔍 Verifying backend API...'
                sh 'curl -f http://localhost:5000/api/products'
            }
        }
    }

    post {
        always {
            echo '🧹 Cleaning up...'
            sh 'docker system prune -f || true'
        }
        failure {
            echo '❌ Pipeline failed!'
            sh 'docker compose logs || true'
        }
        success {
            echo '✅ Pipeline completed successfully!'
        }
    }
}
