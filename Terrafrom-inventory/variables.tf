variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID for EC2"
  default     = "ami-0a0e5d9c7acc336f1" # Amazon Linux 2023 (us-east-1)
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
  default     = "inventory-key-fixed"
}
