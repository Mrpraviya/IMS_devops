#!/bin/bash

# Configuration
EC2_IP="52.54.145.104"
SSH_USER="ec2-user"
BACKEND_IMAGE="sandeeptha/inventory-backend"
FRONTEND_IMAGE="sandeeptha/inventory-frontend"

echo "=== Deploying Inventory Management System to AWS ==="

# 1. Create docker-compose.yml for production
cat > docker-compose.prod.yml << 'DOCKER_COMPOSE'
version: '3.8'
services:
  mongodb:
    image: mongo:latest
    container_name: inventory-mongodb
    restart: always
    ports:
      - "27017:27017"
    volumes:
      - mongodb_data:/data/db
    environment:
      - MONGO_INITDB_ROOT_USERNAME=admin
      - MONGO_INITDB_ROOT_PASSWORD=admin123
      - MONGO_INITDB_DATABASE=inventory
    networks:
      - inventory-network

  backend:
    image: ${BACKEND_IMAGE}:latest
    container_name: inventory-backend
    restart: always
    ports:
      - "5000:5000"
    environment:
      - NODE_ENV=production
      - MONGODB_URI=mongodb://admin:admin123@mongodb:27017/inventory?authSource=admin
      - PORT=5000
      - JWT_SECRET=inventory-secret-key-2024
    depends_on:
      - mongodb
    networks:
      - inventory-network
    volumes:
      - ./backend/uploads:/app/uploads

  frontend:
    image: ${FRONTEND_IMAGE}:latest
    container_name: inventory-frontend
    restart: always
    ports:
      - "80:80"
    environment:
      - REACT_APP_API_URL=http://localhost:5000/api
    depends_on:
      - backend
    networks:
      - inventory-network

networks:
  inventory-network:
    driver: bridge

volumes:
  mongodb_data:
    driver: local
DOCKER_COMPOSE

echo "Created docker-compose.prod.yml"

# 2. Create environment file
cat > .env << 'ENV_FILE'
BACKEND_IMAGE=sandeeptha/inventory-backend:latest
FRONTEND_IMAGE=sandeeptha/inventory-frontend:latest
MONGODB_URI=mongodb://admin:admin123@mongodb:27017/inventory?authSource=admin
JWT_SECRET=inventory-secret-key-2024
ENV_FILE

echo "Created .env file"

# 3. Copy files to EC2 instance
echo "Copying deployment files to EC2 instance..."
scp -o StrictHostKeyChecking=no docker-compose.prod.yml .env ${SSH_USER}@${EC2_IP}:/home/ec2-user/ 2>/dev/null || \
  echo "SCP failed, files saved locally for manual deployment"

# 4. Create deployment script for EC2
cat > remote_deploy.sh << 'REMOTE_SCRIPT'
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
REMOTE_SCRIPT

chmod +x remote_deploy.sh
scp -o StrictHostKeyChecking=no remote_deploy.sh ${SSH_USER}@${EC2_IP}:/home/ec2-user/ 2>/dev/null || \
  echo "Failed to copy deployment script"

echo ""
echo "=== Deployment Instructions ==="
echo "1. Connect to EC2 instance:"
echo "   ssh ec2-user@52.54.145.104"
echo ""
echo "2. Run the deployment script:"
echo "   cd /home/ec2-user"
echo "   chmod +x remote_deploy.sh"
echo "   ./remote_deploy.sh"
echo ""
echo "3. Or manually deploy:"
echo "   cd /home/ec2-user"
echo "   mkdir -p inventory-app"
echo "   cd inventory-app"
echo "   Copy docker-compose.prod.yml and .env"
echo "   sudo docker-compose -f docker-compose.prod.yml up -d"
echo ""
echo "4. Test the application:"
echo "   Backend: http://52.54.145.104:5000"
echo "   Frontend: http://52.54.145.104"
