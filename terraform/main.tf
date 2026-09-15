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
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Create EC2 instance with name "master"
resource "aws_instance" "master" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"   # Free Tier eligible

  root_block_device {
    volume_size = 20           # 20 GB storage (within Free Tier 30 GB limit)
    volume_type = "gp3"        # Free Tier eligible
  }

  tags = {
    Name = "master"
  }
}

