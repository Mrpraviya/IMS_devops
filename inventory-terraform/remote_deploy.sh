#!/bin/bash

echo "=== Starting deployment on EC2 ==="

# Navigate to home directory
cd /home/ec2-user

# Stop any existing containers
echo "Stopping existing containers..."
sudo docker-compose -f docker-compose.prod.yml down || true

# Remove old containers and images
echo "Cleaning up..."
sudo docker system prune -f || true

# Create app directory
mkdir -p inventory-app
cd inventory-app

# Copy deployment files
cp ../docker-compose.prod.yml .
cp ../.env .

# Pull Docker images
echo "Pulling Docker images..."
sudo docker pull sandeeptha/inventory-backend:latest
sudo docker pull sandeeptha/inventory-frontend:latest
sudo docker pull mongo:latest

# Start the application
echo "Starting the application..."
sudo docker-compose -f docker-compose.prod.yml up -d

# Wait for services to start
echo "Waiting for services to start..."
sleep 30

# Check if containers are running
echo "Checking container status..."
sudo docker ps

# Test backend
echo "Testing backend..."
curl -f http://localhost:5000/health || curl -f http://localhost:5000 || echo "Backend check failed"

# Test frontend
echo "Testing frontend..."
curl -f http://localhost:80 || echo "Frontend check failed"

echo "=== Deployment completed ==="
echo "Backend: http://localhost:5000"
echo "Frontend: http://localhost:80"
echo "MongoDB: localhost:27017"
