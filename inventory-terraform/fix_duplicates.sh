#!/bin/bash

# Create a clean version by removing all key_name lines in the EC2 resource
# and adding one back

# Find start and end of EC2 resource
START_LINE=$(grep -n 'resource "aws_instance" "inventory_ec2"' main.tf | cut -d: -f1)
END_LINE=$(awk -v start="$START_LINE" 'NR >= start && /^}/{print NR; exit}' main.tf)

if [ -z "$START_LINE" ] || [ -z "$END_LINE" ]; then
    echo "Could not find EC2 resource"
    exit 1
fi

echo "EC2 resource: lines $START_LINE to $END_LINE"

# Create a new file without the EC2 resource
head -n $((START_LINE-1)) main.tf > main.tf.new

# Add the EC2 resource with single key_name
cat >> main.tf.new << 'EC2_RESOURCE'
resource "aws_instance" "inventory_ec2" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.inventory_sg.id]
  key_name               = var.key_name

  # User data to install Docker and your app
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y

              # Install Docker
              sudo yum install -y docker
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -a -G docker ec2-user

              # Install Docker Compose
              sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              sudo chmod +x /usr/local/bin/docker-compose

              echo "EC2 instance ready for Inventory Management System deployment"
              EOF

  # Root volume
  root_block_device {
    volume_size = 8  # Minimum for free tier
    volume_type = "gp3"
  }

  tags = {
    Name = "${local.name_prefix}-ec2"
    Project = "Inventory Management System"
    Environment = var.environment
  }

  # Lifecycle hook to prevent issues
  lifecycle {
    ignore_changes = [ami]
  }
}
EC2_RESOURCE

# Add the rest of the file
tail -n +$((END_LINE+1)) main.tf >> main.tf.new

# Replace the file
mv main.tf.new main.tf
echo "Fixed: Removed duplicate key_name entries"
