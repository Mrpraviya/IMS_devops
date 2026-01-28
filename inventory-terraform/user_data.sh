 user_data = <<-EOF
#!/bin/bash
set -xe

dnf update -y

# Install Docker
dnf install -y docker
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64" \
-o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install Python
dnf install -y python3

# Create test page
mkdir -p /opt/testapp
cat > /opt/testapp/index.html << 'EOL'
<!DOCTYPE html>
<html>
<head><title>InventoryMS</title></head>
<body>
<h1>Inventory Management System</h1>
<p>Frontend OK (80)</p>
<p>Backend OK (5000)</p>
</body>
</html>
EOL

# Start servers
nohup python3 -m http.server 80 --directory /opt/testapp > /var/log/frontend.log 2>&1 &
nohup python3 -m http.server 5000 --directory /opt/testapp > /var/log/backend.log 2>&1 &

EOF
