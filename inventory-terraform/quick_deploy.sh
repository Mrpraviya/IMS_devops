#!/bin/bash

EC2_IP="52.54.145.104"

echo "Deploying to EC2 instance..."

# Create a simple deployment command
ssh -o StrictHostKeyChecking=no ec2-user@${EC2_IP} << 'DEPLOY_CMDS'
    echo "=== Deploying Inventory Management System ==="
    
    # Create app directory
    cd /home/ec2-user
    mkdir -p inventory-app
    cd inventory-app
    
    # Create docker-compose.yml
    cat > docker-compose.yml << 'DOCKER_YML'
version: '3.8'
services:
  mongodb:
    image: mongo:latest
    container_name: inventory-mongodb
    restart: always
    ports:
      - "27017:27017"
    environment:
      - MONGO_INITDB_DATABASE=inventory
    volumes:
      - mongodb_data:/data/db

  backend:
    image: sandeeptha/inventory-backend:latest
    container_name: inventory-backend
    restart: always
    ports:
      - "5000:5000"
    environment:
      - NODE_ENV=production
      - MONGODB_URI=mongodb://mongodb:27017/inventory
      - PORT=5000
    depends_on:
      - mongodb

  frontend:
    image: sandeeptha/inventory-frontend:latest
    container_name: inventory-frontend
    restart: always
    ports:
      - "80:80"
    depends_on:
      - backend

volumes:
  mongodb_data:
DOCKER_YML
    
    # Stop any existing containers
    sudo docker-compose down || true
    
    # Pull latest images
    echo "Pulling Docker images..."
    sudo docker pull sandeeptha/inventory-backend:latest
    sudo docker pull sandeeptha/inventory-frontend:latest
    sudo docker pull mongo:latest
    
    # Start the application
    echo "Starting application..."
    sudo docker-compose up -d
    
    # Wait and check status
    sleep 20
    echo "Container status:"
    sudo docker ps
    
    echo ""
    echo "=== Deployment Complete ==="
    echo "Backend: http://localhost:5000"
    echo "Frontend: http://localhost:80"
    echo "MongoDB: localhost:27017"
DEPLOY_CMDS

echo ""
echo "=== Access Your Application ==="
echo "Backend API: http://${EC2_IP}:5000"
echo "Frontend: http://${EC2_IP}"
echo "MongoDB: ${EC2_IP}:27017"
