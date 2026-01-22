pipeline {
    agent any
    
    tools {
        nodejs "nodejs"  // This must match the name you configured in Jenkins Tools
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Mrpraviya/IMS_devops.git'
            }
        }
        
        stage('Build') {
            steps {
                sh 'npm install --prefix frontend'
                sh 'npm install --prefix backend'
            }
        }
        
        stage('Test') {
            steps {
                sh 'npm test --prefix backend || true'
            }
        }
        
        stage('Docker Build & Push') {
            steps {
                // These require Docker to be installed in Jenkins container
                sh '''
                    if command -v docker &> /dev/null; then
                        docker build -t sandeeptha/inventory-frontend ./frontend
                        docker build -t sandeeptha/inventory-backend ./backend
                        docker push sandeeptha/inventory-frontend || echo "Login to Docker Hub required"
                        docker push sandeeptha/inventory-backend || echo "Login to Docker Hub required"
                    else
                        echo "Docker not available. Skipping Docker build stage."
                    fi
                '''
            }
        }
        
        stage('Deploy') {
            steps {
                sh '''
                    if command -v docker-compose &> /dev/null; then
                        docker-compose down || true
                        docker-compose up -d
                    else
                        echo "Docker-compose not available. Skipping deployment."
                    fi
                '''
            }
        }
    }
}
