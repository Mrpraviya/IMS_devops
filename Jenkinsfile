pipeline {
    agent any

    environment {
        // Docker Compose project name (optional)
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
                sh 'docker-compose build --no-cache'
            }
        }

        stage('Test') {
            steps {
                echo "🧪 Running tests..."

                // Start containers
                sh 'docker-compose up -d'

                // Wait for backend to be healthy
                sh '''
                echo "⏳ Waiting for backend to be ready..."
                for i in $(seq 1 20); do
                    if docker-compose exec -T backend curl -f http://backend:5000/api/products >/dev/null 2>&1; then
                        echo "✅ Backend is ready!"
                        break
                    fi
                    echo "Waiting... ($i)"
                    sleep 3
                done
                '''

                // Run actual API test
                sh '''
                echo "🔍 Testing backend API..."
                docker-compose exec -T backend curl -f http://backend:5000/api/products || exit 1
                '''
            }
        }

        stage('Deploy') {
            when {
                expression { currentBuild.resultIsBetterOrEqualTo('SUCCESS') }
            }
            steps {
                echo "🚀 Deploying containers..."
                sh 'docker-compose up -d'
            }
        }

        stage('Verify Deployment') {
            when {
                expression { currentBuild.resultIsBetterOrEqualTo('SUCCESS') }
            }
            steps {
                echo "🔎 Verifying deployment..."
                sh '''
                docker-compose exec -T backend curl -f http://backend:5000/api/products || exit 1
                docker-compose exec -T frontend curl -f http://frontend:80 || exit 1
                '''
            }
        }
    }

    post {
        always {
            echo "🧹 Cleaning up unused Docker resources..."
            sh 'docker system prune -f'
        }

        success {
            echo "✅ Pipeline completed successfully!"
        }

        failure {
            echo "❌ Pipeline failed!"
            sh 'docker-compose logs --tail=50'
        }
    }
}
