#!/bin/bash

EC2_IP="52.54.145.104"

echo "Deploying MERN Inventory System to ${EC2_IP}..."

# Connect and deploy
ssh -o StrictHostKeyChecking=no ec2-user@${EC2_IP} << 'DEPLOY'
    echo "=== Starting deployment ==="
    
    # Go to home directory
    cd /home/ec2-user
    
    # Create docker-compose file
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
      - MONGO_INITDB_DATABASE=inventorydb
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
      - MONGODB_URI=mongodb://mongodb:27017/inventorydb
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
    driver: local
DOCKER_YML
    
    # Stop any existing containers
    sudo docker-compose down || true
    
    # Pull and start
    echo "Pulling images..."
    sudo docker-compose pull
    echo "Starting containers..."
    sudo docker-compose up -d
    
    echo "Waiting for startup..."
    sleep 30
    
    # Check status
    echo "=== Deployment Status ==="
    sudo docker ps
    
    # Test
    echo ""
    echo "=== Testing ==="
    echo "Backend test:"
    curl -s http://localhost:5000 || echo "Backend not ready"
    echo ""
    echo "Frontend test:"
    curl -s http://localhost:80 | grep -o "<title>[^<]*</title>" || echo "No title found"
    
    echo ""
    echo "=== Deployment Complete ==="
    echo "Access your application:"
    echo "- Frontend: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
    echo "- Backend: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):5000"
DEPLOY

echo ""
echo "=== Your Application is Deployed! ==="
echo "🌐 Frontend: http://${EC2_IP}"
echo "⚙️  Backend API: http://${EC2_IP}:5000"
echo "🗄️  MongoDB: ${EC2_IP}:27017"
echo ""
echo "To check logs: ssh ec2-user@${EC2_IP} 'sudo docker-compose logs'"
echo "To restart: ssh ec2-user@${EC2_IP} 'sudo docker-compose restart'"
