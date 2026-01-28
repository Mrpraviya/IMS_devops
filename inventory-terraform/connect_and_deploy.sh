#!/bin/bash

echo "Connecting to EC2 instance..."
ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 ec2-user@52.54.145.104 << 'SSH_EOF'
    echo "=== Checking EC2 instance status ==="
    echo "Current directory: $(pwd)"
    echo "Docker status:"
    sudo docker --version
    sudo docker-compose --version
    echo "Running containers:"
    sudo docker ps
    echo ""
    echo "=== Current setup ==="
    ls -la /home/ec2-user/
    echo ""
    echo "=== Checking ports ==="
    sudo netstat -tulpn | grep :5000 || echo "Port 5000 not listening"
    sudo netstat -tulpn | grep :80 || echo "Port 80 not listening"
    echo ""
    echo "=== Testing web server ==="
    curl -s http://localhost:5000 || echo "Local port 5000 not responding"
    curl -s http://localhost:80 || echo "Local port 80 not responding"
SSH_EOF
