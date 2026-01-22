pipeline {
    agent any
    
    tools {
        nodejs "nodejs"  // Assuming you configured NodeJS in Jenkins
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
                // These will fail if Docker is not installed
                sh 'docker build -t sandeeptha/inventory-frontend ./frontend || echo "Docker not available, skipping build"'
                sh 'docker build -t sandeeptha/inventory-backend ./backend || echo "Docker not available, skipping build"'
                sh 'docker push sandeeptha/inventory-frontend || echo "Docker not available, skipping push"'
                sh 'docker push sandeeptha/inventory-backend || echo "Docker not available, skipping push"'
            }
        }
        
        stage('Deploy') {
            steps {
                sh 'docker-compose down || true'
                sh 'docker-compose up -d || echo "Docker compose not available"'
            }
        }
    }
}
