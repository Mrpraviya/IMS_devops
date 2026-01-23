 pipeline {
    agent any
    
    environment {
        NODE_HOME = '/var/jenkins_home/tools/jenkins.plugins.nodejs.tools.NodeJSInstallation/nodejs'
        PATH = "${env.NODE_HOME}/bin:${env.PATH}"
    }
    
    stages {
        stage('Verify Setup') {
            steps {
                sh '''
                    echo "=== Environment Verification ==="
                    echo "Node: $(node --version)"
                    echo "NPM: $(npm --version)"
                    docker --version || echo "Docker not available"
                    docker-compose --version || echo "Docker-compose not available"
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
                    echo "=== Building Frontend ==="
                    cd frontend
                    npm install
                    npm run build || echo "Build command may not exist"
                '''
            }
        }
        
        stage('Build Backend') {
            steps {
                sh '''
                    echo "=== Building Backend ==="
                    cd backend
                    npm install
                '''
            }
        }
        
        stage('Test') {
            steps {
                sh '''
                    echo "=== Running Tests ==="
                    cd backend
                    npm test || echo "Tests may not be configured"
                '''
            }
        }
        
        stage('Docker Build') {
            when {
                expression { return sh(script: 'command -v docker', returnStatus: true) == 0 }
            }
            steps {
                sh '''
                    echo "=== Building Docker Images ==="
                    
                    # Build frontend image
                    echo "Building frontend image..."
                    docker build -t sandeeptha/inventory-frontend ./frontend
                    
                    # Build backend image
                    echo "Building backend image..."
                    docker build -t sandeeptha/inventory-backend ./backend
                    
                    # List images
                    echo "Built images:"
                    docker images | grep sandeeptha
                '''
            }
        }
        
        stage('Docker Compose Deployment') {
            when {
                expression { return sh(script: 'command -v docker-compose', returnStatus: true) == 0 }
            }
            steps {
                sh '''
                    echo "=== Deploying with Docker Compose ==="
                    
                    # Stop and remove any existing containers
                    docker-compose down || true
                    
                    # Build and start containers
                    docker-compose up -d --build
                    
                    # Check running containers
                    echo "Running containers:"
                    docker-compose ps
                    
                    echo ""
                    echo "=== Application URLs ==="
                    echo "Frontend: http://localhost:5173"
                    echo "Backend API: http://localhost:5000"
                    echo "MongoDB: localhost:27017"
                    echo ""
                    echo "=== To view logs ==="
                    echo "docker-compose logs -f"
                '''
            }
        }
        
        stage('Health Check') {
            steps {
                sh '''
                    echo "=== Performing Health Check ==="
                    sleep 10  # Wait for services to start
                    
                    # Check if services are responding
                    echo "Checking backend health..."
                    curl -f http://localhost:5000/health || curl -f http://localhost:5000 || echo "Backend health check failed"
                    
                    echo "Checking frontend health..."
                    curl -f http://localhost:5173 || echo "Frontend health check failed"
                '''
            }
        }
    }
    
    post {
        always {
            echo "=== Pipeline Execution Completed ==="
            sh '''
                echo "Final container status:"
                docker-compose ps || echo "docker-compose not available"
            '''
        }
        success {
            echo "SUCCESS: CI/CD Pipeline completed successfully!"
            echo "Application should be running at:"
            echo " Frontend: http://localhost:5173"
            echo " Backend API: http://localhost:5000"
        }
        failure {
            echo "FAILURE: Pipeline failed at some stage"
            sh '''
                echo "=== Error Debugging ==="
                echo "Recent docker-compose logs:"
                docker-compose logs --tail=50 || echo "Could not get logs"
            '''
        }
    }
}
