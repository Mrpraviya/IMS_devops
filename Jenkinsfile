pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE_BACKEND = 'ims-backend'
        DOCKER_IMAGE_FRONTEND = 'ims-frontend'
        COMPOSE_PROJECT_NAME = 'ims_devops'
    }
    
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
                sh 'docker-compose build --no-cache'
            }
        }
        
        stage('Test') {
            steps {
                echo '🧪 Running tests...'
                sh '''
                    echo "Starting containers for testing..."
                    docker-compose up -d
                    sleep 10
                    
                    echo "Testing backend API..."
                    curl -f http://localhost:5000/api/products || exit 1
                    
                    echo "✅ Tests passed!"
                '''
            }
        }
        
        stage('Deploy') {
            steps {
                echo '🚀 Deploying application...'
                sh '''
                    docker-compose down
                    docker-compose up -d
                    docker-compose ps
                '''
            }
        }
        
        stage('Verify Deployment') {
            steps {
                echo '✔️ Verifying deployment...'
                sh '''
                    sleep 5
                    
                    echo "Testing backend via nginx proxy..."
                    curl -f http://localhost/api/products || exit 1
                    
                    echo "Testing frontend..."
                    curl -f http://localhost/ | grep -q "S&P Inventory" || exit 1
                    
                    echo "✅ Deployment successful!"
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
            sh 'docker-compose logs --tail=50'
        }
        always {
            echo '🧹 Cleaning up unused Docker resources...'
            sh 'docker system prune -f'
        }
    }
}
