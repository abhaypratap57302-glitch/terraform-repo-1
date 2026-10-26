terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-2"
}

resource "aws_key_pair" "terraform_keys" {
  key_name   = "my-terra-key"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHj1vbZLY1WGsucyegzIOIBAXo4hpEQIaNI4gEqsZERw ubuntu@ip-172-31-37-64"
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "aws-Default VPC"
  }
}

resource "aws_security_group" "my_security_group" {
  name   = "my-sg"
  vpc_id = aws_default_vpc.default.id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "my-sg"
  }
}

resource "aws_instance" "my_instance" {
  key_name               = aws_key_pair.terraform_keys.key_name
  vpc_security_group_ids = [aws_security_group.my_security_group.id]
  instance_type          = "t3.micro"
  ami                    = "ami-0dd60a46ecc6eac16" # ubuntu

  root_block_device {
    volume_size = 15
    volume_type = "gp3"
  }

  tags = {
    Name = "my-terra-ec2-1"
  }
}
