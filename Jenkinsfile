pipeline {
    agent any
    environment {
        COMPOSE_PROJECT_NAME = 'ims_devops'
    }
    stages {
        stage('Checkout SCM') {
            steps {
                echo "🔄 Pulling latest code from GitHub..."
                checkout scm
            }
        }
        stage('Build') {
            steps {
                echo "🏗️ Building Docker images..."
                // Only build if not already built
                sh 'docker-compose build'
            }
        }
        stage('Test') {
            steps {
                echo "🧪 Running tests..."
                sh 'docker-compose up -d'
                sh '''
                echo "⏳ Waiting for backend..."
                for i in $(seq 1 15); do
                    if docker-compose exec -T backend curl -f http://backend:5000/api/products 2>/dev/null; then
                        echo "✅ Backend ready!"
                        break
                    fi
                    echo "Waiting... ($i)"
                    sleep 2
                done
                '''
                sh 'docker-compose exec -T backend curl -f http://backend:5000/api/products'
            }
        }
        stage('Deploy') {
            steps {
                echo "🚀 Deploying..."
                sh 'docker-compose up -d'
            }
        }
        stage('Verify') {
            steps {
                echo "🔎 Verifying..."
                sh '''
                docker-compose exec -T backend curl -f http://backend:5000/api/products || exit 1
                docker-compose exec -T frontend curl -f http://frontend:80 || exit 1
                echo "✅ Deployment successful!"
                '''
            }
        }
    }
    post {
        always {
            echo "🧹 Cleaning up..."
            sh 'docker system prune -f'
        }
        success {
            echo "✅ Pipeline completed successfully!"
        }
        failure {
            echo "❌ Pipeline failed!"
            sh 'docker-compose logs --tail=20'
        }
    }
}
