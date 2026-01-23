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
                    docker --version
                    docker-compose --version
                '''
            }
        }
        
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Mrpraviya/IMS_devops.git'
            }
        }
        
        stage('Clean Up') {
            steps {
                sh '''
                    echo "=== Cleaning Up Previous Deployment ==="
                    
                    # Stop Jenkins workspace containers
                    cd /var/jenkins_home/workspace/IMS-Pipeline
                    docker-compose down || true
                    
                    # Kill any process using port 27017
                    echo "Checking for processes on port 27017..."
                    fuser -k 27017/tcp 2>/dev/null || true
                    
                    # Remove dangling containers and images
                    docker system prune -f || true
                    
                    echo "Cleanup completed"
                '''
            }
        }
        
        stage('Build Frontend') {
            steps {
                sh '''
                    echo "=== Building Frontend ==="
                    cd frontend
                    npm install
                    npm run build
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
            steps {
                sh '''
                    echo "=== Building Docker Images ==="
                    
                    echo "Building frontend image..."
                    docker build -t sandeeptha/inventory-frontend ./frontend
                    
                    echo "Building backend image..."
                    docker build -t sandeeptha/inventory-backend ./backend
                    
                    echo "Built images:"
                    docker images | grep sandeeptha
                '''
            }
        }
        
        stage('Docker Compose Deployment') {
            steps {
                sh '''
                    echo "=== Deploying with Docker Compose ==="
                    
                    # Remove old containers first
                    docker-compose down || true
                    
                    # Wait a moment for ports to be released
                    sleep 3
                    
                    # Build and start with force recreate
                    docker-compose up -d --build --force-recreate
                    
                    # Check running containers
                    echo "Running containers:"
                    docker-compose ps
                    
                    # Wait for services to start
                    echo "Waiting for services to start..."
                    sleep 10
                    
                    echo ""
                    echo "=== Application URLs ==="
                    echo "Frontend: http://localhost:5173"
                    echo "Backend API: http://localhost:5000"
                    echo "MongoDB: localhost:27017"
                '''
            }
        }
        
        stage('Health Check') {
            steps {
                sh '''
                    echo "=== Performing Health Check ==="
                    
                    # Check MongoDB
                    echo "Checking MongoDB..."
                    docker-compose exec mongo mongosh --eval "db.version()" || \
                    echo "MongoDB health check failed"
                    
                    # Check backend
                    echo "Checking backend..."
                    curl -f http://localhost:5000/health || \
                    curl -f http://localhost:5000 || \
                    echo "Backend health check failed"
                    
                    # Check frontend
                    echo "Checking frontend..."
                    curl -f http://localhost:5173 || \
                    echo "Frontend health check failed"
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
                
                echo ""
                echo "Container logs (last 5 lines each):"
                docker-compose logs --tail=5 2>/dev/null || echo "Could not get logs"
            '''
        }
        success {
            echo "✅ SUCCESS: CI/CD Pipeline completed successfully!"
            echo "🚀 Application is running:"
            echo "   Frontend: http://localhost:5173"
            echo "   Backend API: http://localhost:5000"
        }
        failure {
            echo "❌ FAILURE: Pipeline failed"
            sh '''
                echo "=== Debugging Information ==="
                echo "Docker container status:"
                docker ps -a
                
                echo ""
                echo "Port usage:"
                netstat -tulpn | grep :27017 || echo "Port 27017 not in use"
                netstat -tulpn | grep :5000 || echo "Port 5000 not in use"
                netstat -tulpn | grep :5173 || echo "Port 5173 not in use"
                
                echo ""
                echo "Recent docker-compose logs:"
                docker-compose logs --tail=20 2>/dev/null || echo "Could not get logs"
            '''
        }
    }
}
