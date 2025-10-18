terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Use the default VPC + a default subnet
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  # default-for-az is true for default subnets
  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

# Simple security group: allow HTTP (80) and SSH (22) from anywhere
resource "aws_security_group" "web_sg" {
  name        = "ec2-hello-web-sg"
  description = "Allow HTTP & SSH"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-hello-sg"
  }
}

# Latest Amazon Linux 2 AMI
data "aws_ami" "al2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  owners = ["137112412989"] # Amazon
}

# EC2 instance
resource "aws_instance" "hello" {
  ami                         = data.aws_ami.al2.id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              echo "<h1>Hello from Terraform EC2 🎉</h1><p>$(uname -a)</p>" > /var/www/html/index.html
              systemctl enable httpd
              systemctl start httpd
              EOF

  tags = {
    Name = "ec2-hello"
  }
}

# ---- Variables & Outputs ----
variable "instance_type" {
  type    = string
  default = "t2.micro"
}

output "public_ip" {
  value = aws_instance.hello.public_ip
}

output "hello_url" {
  value = "http://${aws_instance.hello.public_dns}"
}
