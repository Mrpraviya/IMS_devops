#!/bin/bash

EC2_IP="52.54.145.104"
echo "Testing deployment on ${EC2_IP}..."

echo "=== Testing Backend (Port 5000) ==="
for i in {1..5}; do
    if curl -s --max-time 5 "http://${EC2_IP}:5000" > /dev/null; then
        echo "✅ Backend is responding on port 5000"
        curl -s "http://${EC2_IP}:5000" | head -20
        break
    else
        echo "Attempt ${i}: Backend not ready yet..."
        sleep 10
    fi
done

echo ""
echo "=== Testing Frontend (Port 80) ==="
for i in {1..5}; do
    if curl -s --max-time 5 "http://${EC2_IP}" > /dev/null; then
        echo "✅ Frontend is responding on port 80"
        curl -s "http://${EC2_IP}" | grep -o "<title>[^<]*</title>" || echo "No title found"
        break
    else
        echo "Attempt ${i}: Frontend not ready yet..."
        sleep 10
    fi
done

echo ""
echo "=== Testing MongoDB (Port 27017) ==="
nc -zv ${EC2_IP} 27017 && echo "✅ MongoDB port is open" || echo "❌ MongoDB port not accessible"

echo ""
echo "=== Checking Docker Containers ==="
ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 ec2-user@${EC2_IP} "sudo docker ps" 2>/dev/null || \
    echo "Could not connect to check Docker status"

echo ""
echo "=== Summary ==="
echo "Application URLs:"
echo "  Frontend: http://${EC2_IP}"
echo "  Backend API: http://${EC2_IP}:5000"
echo "  MongoDB: mongodb://${EC2_IP}:27017/inventory"
