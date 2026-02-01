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
                    if docker-compose exec -T backend curl -f http://backend:5000/api/products >/dev/null 2>&1; then
                        echo "✅ Backend ready!"
                        exit 0
                    fi
                    echo "Waiting... ($i)"
                    sleep 2
                done
                echo "❌ Backend not ready"
                exit 1
                '''
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
                docker-compose exec -T backend curl -f http://backend:5000/api/products
                docker-compose exec -T frontend curl -f http://frontend
                echo "✅ Deployment successful!"
                '''
            }
        }
    }

    post {
        always {
            echo "🧹 Cleaning up..."
            sh 'docker system prune -f || true'
        }

        success {
            echo "✅ Pipeline completed successfully!"
        }

        failure {
            echo "❌ Pipeline failed!"
            sh 'docker-compose logs'
        }
    }
}
