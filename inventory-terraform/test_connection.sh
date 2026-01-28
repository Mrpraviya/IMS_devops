#!/bin/bash
IP="52.54.145.104"

echo "1. Testing SSH..."
timeout 10 ssh -o ConnectTimeout=10 -i inventory-key ec2-user@$IP "echo 'SSH successful'; hostname" && echo "✅ SSH OK" || echo "❌ SSH failed"

echo -e "\n2. Testing HTTP (Port 80)..."
curl -s -f --connect-timeout 10 http://$IP && echo "✅ HTTP OK" || echo "❌ HTTP failed"

echo -e "\n3. Testing Port 5000..."
curl -s -f --connect-timeout 10 http://${IP}:5000 && echo "✅ Port 5000 OK" || echo "❌ Port 5000 failed"

echo -e "\n4. Checking instance status..."
aws ec2 describe-instance-status --instance-ids i-0876a1ac68d7d5e57 --query "InstanceStatuses[0].{State:InstanceState.Name, Status:InstanceStatus.Status}" --output table
