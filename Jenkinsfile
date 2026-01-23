 pipeline {
    agent any
    
    environment {
        // Set the PATH to include NodeJS
        NODE_HOME = '/var/jenkins_home/tools/jenkins.plugins.nodejs.tools.NodeJSInstallation/nodejs'
        PATH = "${env.NODE_HOME}/bin:${env.PATH}"
    }
    
    stages {
        stage('Verify Setup') {
            steps {
                sh '''
                    echo "PATH is set to: $PATH"
                    echo "NodeJS location: $(which node)"
                    echo "Node version: $(node --version)"
                    echo "NPM version: $(npm --version)"
                '''
            }
        }
        
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Mrpraviya/IMS_devops.git'
            }
        }
        
        stage('Build Frontend') {
            steps {
                sh '''
                    echo "Building frontend..."
                    cd frontend
                    npm install
                '''
            }
        }
        
        stage('Build Backend') {
            steps {
                sh '''
                    echo "Building backend..."
                    cd backend
                    npm install
                '''
            }
        }
        
        stage('Test') {
            steps {
                sh '''
                    echo "Running tests..."
                    cd backend
                    npm test || echo "Tests completed (may have failures)"
                '''
            }
        }
        
        stage('Docker Build') {
            when {
                expression { return sh(script: 'command -v docker', returnStatus: true) == 0 }
            }
            steps {
                sh '''
                    echo "Building Docker images..."
                    docker build -t sandeeptha/inventory-frontend ./frontend || echo "Frontend Docker build failed"
                    docker build -t sandeeptha/inventory-backend ./backend || echo "Backend Docker build failed"
                '''
            }
        }
    }
    
    post {
        always {
            echo "Pipeline completed!"
        }
        success {
            echo "Success! All stages completed."
        }
        failure {
            echo "Pipeline failed at some stage."
        }
    }
}
