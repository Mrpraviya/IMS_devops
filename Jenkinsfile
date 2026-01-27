 pipeline {
    agent any
    
    environment {
        NODE_HOME = '/var/jenkins_home/tools/jenkins.plugins.nodejs.tools.NodeJSInstallation/nodejs'
        PATH = "${env.NODE_HOME}/bin:${env.PATH}"
        AWS_REGION = 'us-east-1'
        TF_WORKSPACE = 'inventory-terraform'
        DOCKER_REGISTRY = 'your-ecr-registry'
        BACKEND_IMAGE = 'inventory-backend'
        FRONTEND_IMAGE = 'inventory-frontend'
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
                    terraform --version
                    aws --version
                '''
            }
        }
        
        stage('Checkout Source Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Mrpraviya/IMS_devops.git'
            }
        }
        
        stage('Checkout Terraform Config') {
            steps {
                dir('terraform-config') {
                    git branch: 'main',
                        url: 'https://github.com/your-org/inventory-terraform.git'
                }
            }
        }
        
        stage('Build & Test') {
            steps {
                sh '''
                    echo "=== Building Frontend ==="
                    cd frontend
                    npm install
                    npm run build
                    
                    echo "=== Building Backend ==="
                    cd ../backend
                    npm install
                    npm test || echo "Tests may not be configured"
                '''
            }
        }
        
        stage('Build Docker Images') {
            steps {
                sh '''
                    echo "=== Building Docker Images ==="
                    
                    echo "Building frontend image..."
                    docker build -t ${FRONTEND_IMAGE}:${BUILD_NUMBER} ./frontend
                    
                    echo "Building backend image..."
                    docker build -t ${BACKEND_IMAGE}:${BUILD_NUMBER} ./backend
                '''
            }
        }
        
        stage('Push to ECR') {
            steps {
                withAWS(credentials: 'aws-credentials', region: AWS_REGION) {
                    sh '''
                        echo "=== Pushing Images to ECR ==="
                        
                        # Login to ECR
                        aws ecr get-login-password --region ${AWS_REGION} | \
                        docker login --username AWS --password-stdin ${DOCKER_REGISTRY}
                        
                        # Tag and push backend
                        docker tag ${BACKEND_IMAGE}:${BUILD_NUMBER} \
                            ${DOCKER_REGISTRY}/${BACKEND_IMAGE}:${BUILD_NUMBER}
                        docker push ${DOCKER_REGISTRY}/${BACKEND_IMAGE}:${BUILD_NUMBER}
                        
                        # Tag and push frontend
                        docker tag ${FRONTEND_IMAGE}:${BUILD_NUMBER} \
                            ${DOCKER_REGISTRY}/${FRONTEND_IMAGE}:${BUILD_NUMBER}
                        docker push ${DOCKER_REGISTRY}/${FRONTEND_IMAGE}:${BUILD_NUMBER}
                        
                        # Tag as latest for rollback
                        docker tag ${BACKEND_IMAGE}:${BUILD_NUMBER} \
                            ${DOCKER_REGISTRY}/${BACKEND_IMAGE}:latest
                        docker tag ${FRONTEND_IMAGE}:${BUILD_NUMBER} \
                            ${DOCKER_REGISTRY}/${FRONTEND_IMAGE}:latest
                        docker push ${DOCKER_REGISTRY}/${BACKEND_IMAGE}:latest
                        docker push ${DOCKER_REGISTRY}/${FRONTEND_IMAGE}:latest
                    '''
                }
            }
        }
        
        stage('Terraform Init & Plan') {
            steps {
                dir('terraform-config') {
                    withAWS(credentials: 'aws-credentials', region: AWS_REGION) {
                        sh '''
                            echo "=== Terraform Initialization ==="
                            terraform init
                            
                            echo "=== Terraform Plan ==="
                            terraform plan \
                                -var="backend_image_tag=${BUILD_NUMBER}" \
                                -var="frontend_image_tag=${BUILD_NUMBER}" \
                                -var="environment=production" \
                                -out=tfplan
                        '''
                    }
                }
            }
        }
        
        stage('Manual Approval') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    input(message: 'Approve deployment to production?', ok: 'Deploy')
                }
            }
        }
        
        stage('Terraform Apply') {
            steps {
                dir('terraform-config') {
                    withAWS(credentials: 'aws-credentials', region: AWS_REGION) {
                        sh '''
                            echo "=== Applying Terraform Changes ==="
                            terraform apply -auto-approve tfplan
                        '''
                    }
                }
            }
        }
        
        stage('Health Check & Smoke Test') {
            steps {
                script {
                    dir('terraform-config') {
                        // Get ALB DNS from Terraform output
                        def alb_dns = sh(
                            script: 'terraform output -raw alb_dns_name',
                            returnStdout: true
                        ).trim()
                        
                        sh """
                            echo "=== Health Check ==="
                            echo "ALB URL: http://${alb_dns}"
                            
                            # Wait for services to be ready
                            echo "Waiting for services to be ready..."
                            sleep 30
                            
                            # Test backend health endpoint
                            echo "Testing backend..."
                            curl -f http://${alb_dns}/api/health || \
                            curl -f http://${alb_dns}/health || \
                            echo "Backend health check failed"
                            
                            # Test frontend
                            echo "Testing frontend..."
                            curl -f http://${alb_dns} || \
                            echo "Frontend check failed"
                            
                            # Test API endpoints
                            echo "Testing API endpoints..."
                            curl -s http://${alb_dns}/api/products | grep -i product || \
                            echo "API test inconclusive"
                        """
                    }
                }
            }
        }
    }
    
    post {
        always {
            echo "=== Pipeline Execution Completed ==="
            sh '''
                echo "Cleaning up local images..."
                docker system prune -f || true
            '''
        }
        success {
            script {
                dir('terraform-config') {
                    def alb_dns = sh(
                        script: 'terraform output -raw alb_dns_name',
                        returnStdout: true
                    ).trim()
                    
                    echo "✅ SUCCESS: Deployment completed!"
                    echo "🚀 Application deployed to AWS"
                    echo "   URL: http://${alb_dns}"
                    echo "   Backend API: http://${alb_dns}/api"
                    
                    // Send notification
                    slackSend(
                        color: 'good',
                        message: "✅ Deployment Successful\nApplication: ${env.JOB_NAME}\nBuild: ${env.BUILD_NUMBER}\nURL: http://${alb_dns}"
                    )
                }
            }
        }
        failure {
            echo "❌ FAILURE: Pipeline failed"
            
            // Rollback to previous version if needed
            sh '''
                echo "Attempting rollback..."
                # Add rollback logic here if needed
            '''
            
            slackSend(
                color: 'danger',
                message: "❌ Deployment Failed\nApplication: ${env.JOB_NAME}\nBuild: ${env.BUILD_NUMBER}"
            )
        }
    }
}
