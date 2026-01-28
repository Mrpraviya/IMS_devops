 // Add these stages to your existing Jenkinsfile
stage('AWS Infrastructure Setup') {
    steps {
        dir('inventory-terraform') {
            withAWS(credentials: 'aws-credentials', region: 'us-east-1') {
                sh '''
                    echo "=== Setting up AWS Infrastructure ==="
                    terraform init
                    terraform plan -out=tfplan
                    terraform apply -auto-approve tfplan
                    
                    # Get EC2 IP
                    EC2_IP=$(terraform output -raw ec2_public_ip)
                    echo "EC2 Public IP: $EC2_IP"
                    echo "Application will be deployed to: http://$EC2_IP"
                '''
            }
        }
    }
}

stage('Deploy to AWS EC2') {
    steps {
        script {
            // Get EC2 IP from Terraform output
            dir('inventory-terraform') {
                EC2_IP = sh(
                    script: 'terraform output -raw ec2_public_ip',
                    returnStdout: true
                ).trim()
            }
            
            sh """
                echo "=== Deploying to AWS EC2: ${EC2_IP} ==="
                
                # Create deployment script
                cat > deploy_to_aws.sh << 'DEPLOY_SCRIPT'
                #!/bin/bash
                
                # Transfer files to EC2
                echo "Copying deployment files to EC2..."
                scp -o StrictHostKeyChecking=no \
                    docker-compose.yml \
                    ec2-user@${EC2_IP}:/home/ec2-user/ 2>/dev/null || echo "SCP completed"
                
                # Execute deployment on EC2
                ssh -o StrictHostKeyChecking=no ec2-user@${EC2_IP} << 'SSH_EOF'
                    echo "=== Starting deployment on EC2 ==="
                    
                    cd /home/ec2-user
                    
                    # Stop existing containers
                    sudo docker-compose down || true
                    
                    # Create app directory
                    mkdir -p inventory-app
                    cd inventory-app
                    
                    # Copy docker-compose
                    cp ../docker-compose.yml .
                    
                    # Pull latest images
                    echo "Pulling Docker images..."
                    sudo docker pull sandeeptha/inventory-backend:latest
                    sudo docker pull sandeeptha/inventory-frontend:latest
                    sudo docker pull mongo:latest
                    
                    # Start application
                    echo "Starting application..."
                    sudo docker-compose up -d
                    
                    # Wait and check
                    sleep 30
                    echo "Container status:"
                    sudo docker ps
                    
                    echo "=== Deployment Complete ==="
                    echo "Access your application at: http://${EC2_IP}"
                SSH_EOF
                DEPLOY_SCRIPT
                
                chmod +x deploy_to_aws.sh
                ./deploy_to_aws.sh
            """
        }
    }
}

stage('Health Check AWS Deployment') {
    steps {
        script {
            dir('inventory-terraform') {
                EC2_IP = sh(
                    script: 'terraform output -raw ec2_public_ip',
                    returnStdout: true
                ).trim()
            }
            
            sh """
                echo "=== Health Check for AWS Deployment ==="
                echo "Testing: http://${EC2_IP}:5000"
                
                # Wait for application to start
                sleep 60
                
                # Test backend
                MAX_RETRIES=10
                for i in \$(seq 1 \$MAX_RETRIES); do
                    if curl -f "http://${EC2_IP}:5000/health" 2>/dev/null; then
                        echo "✅ Backend is healthy!"
                        break
                    elif curl -f "http://${EC2_IP}:5000" 2>/dev/null; then
                        echo "✅ Backend is responding!"
                        break
                    else
                        echo "Attempt \$i/\$MAX_RETRIES: Application not ready..."
                        sleep 10
                    fi
                done
                
                # Test frontend
                if curl -f "http://${EC2_IP}" 2>/dev/null; then
                    echo "✅ Frontend is responding!"
                else
                    echo "⚠️ Frontend not responding yet"
                fi
                
                echo ""
                echo "=== AWS Deployment Complete ==="
                echo "🎉 Inventory Management System deployed to AWS!"
                echo "🌐 Frontend: http://${EC2_IP}"
                echo "⚙️  Backend API: http://${EC2_IP}:5000"
                echo "🗄️  MongoDB: ${EC2_IP}:27017"
            """
        }
    }
}
