 provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "inventory_sg" {
  name = "inventory-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "inventory_ec2" {
  ami           = "ami-0c02fb55956c7d316"   # Amazon Linux 2
  instance_type = "t2.micro"
  key_name      = "inventory-key"

  vpc_security_group_ids = [aws_security_group.inventory_sg.id]

  user_data = file("user_data.sh")

  tags = {
    Name = "InventoryMS-Server"
  }
}
