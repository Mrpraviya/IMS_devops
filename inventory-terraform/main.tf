terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Random suffix for unique names
resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  name_prefix = "inventory-${var.environment}"
}

# 1. Create VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = "${local.name_prefix}-vpc"
  }
}

# 2. Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "${local.name_prefix}-igw"
  }
}

# 3. Create Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true
  
  tags = {
    Name = "${local.name_prefix}-public-subnet"
  }
}

# 4. Create Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  
  tags = {
    Name = "${local.name_prefix}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# 5. Create Security Group for EC2
resource "aws_security_group" "inventory_sg" {
  name        = "${local.name_prefix}-sg"
  description = "Security group for Inventory Management System"
  vpc_id      = aws_vpc.main.id

  # Allow SSH access
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Allow HTTP for backend (Port 5000)
  ingress {
    description = "Backend API"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Allow HTTP for frontend (Port 80)
  ingress {
    description = "Frontend"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "${local.name_prefix}-sg"
  }
}

# 6. Get latest Amazon Linux AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# 7. Create EC2 Instance with fallback instance types
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

              # Create a simple test web server if your app isn't ready
              cd /home/ec2-user
              
              # Create a simple HTML page for testing
              cat > index.html << 'EOL'
              <!DOCTYPE html>
              <html>
              <head>
                  <title>Inventory Management System</title>
              </head>
              <body>
                  <h1>Inventory Management System</h1>
                  <p>Backend: <a href="http://localhost:5000">Port 5000</a></p>
                  <p>Frontend: <a href="http://localhost:80">Port 80</a></p>
              </body>
              </html>
              EOL
              
              # Install Python if not present
              sudo yum install -y python3
              
              # Start a simple Python HTTP server on port 80 for testing
              sudo python3 -m http.server 80 --directory /home/ec2-user &
              
              # Start a test server on port 5000
              sudo python3 -m http.server 5000 --directory /home/ec2-user &
              
              echo "Test web servers started on ports 80 and 5000"
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

# 8. Elastic IP for static IP address
resource "aws_eip" "inventory_eip" {
  instance = aws_instance.inventory_ec2.id
  domain   = "vpc"
  
  tags = {
    Name = "${local.name_prefix}-eip"
  }
}

# 9. Output the instance type being used for debugging
output "actual_instance_type" {
  value = aws_instance.inventory_ec2.instance_type
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "Public Subnet ID"
  value       = aws_subnet.public.id
}

output "security_group_id" {
  description = "Security Group ID"
  value       = aws_security_group.inventory_sg.id
}

output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.inventory_ec2.public_ip
}

output "ec2_eip" {
  description = "Elastic IP of the EC2 instance"
  value       = aws_eip.inventory_eip.public_ip
}

output "ec2_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.inventory_ec2.id
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh ec2-user@${aws_eip.inventory_eip.public_ip}"
}

output "backend_url" {
  description = "URL to access the backend"
  value       = "http://${aws_eip.inventory_eip.public_ip}:5000"
}

output "frontend_url" {
  description = "URL to access the frontend"
  value       = "http://${aws_eip.inventory_eip.public_ip}"
}

output "ami_id" {
  description = "AMI ID used for the instance"
  value       = data.aws_ami.amazon_linux.id
}
