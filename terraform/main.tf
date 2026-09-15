terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"   # Free Tier eligible region
}

# Lookup latest Ubuntu 22.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (official Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security group allowing SSH only from your IP
resource "aws_security_group" "ssh" {
  name        = "allow-ssh"
  description = "Allow SSH from my IP"
  vpc_id      = "vpc-09992f3ca0e60806b"   # Replace with your actual VPC ID

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Replace with your IP (e.g. 203.0.113.25/32)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 instance
resource "aws_instance" "master" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name      = "terra_key"   # Replace with the name of your AWS key pair
  vpc_security_group_ids = [aws_security_group.ssh.id]

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "master"
  }
}

# Output the public IP so you can connect
output "instance_public_ip" {
  value = aws_instance.master.public_ip
}

