terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.46"
    }
  }
  required_version = "1.13.1"

  backend "s3" {
    bucket         = "hackathon-devs2blu-terraform-state-1533"
    key            = "hackathon/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "hackathon-terraform-locks"
    encrypt        = true
  }
}
provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Project   = "Hackathon-Devs2Blu"
      ManagedBy = "Terraform"

    }
  }
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = ["vpc-06786ee7f7a163059"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "emergency_sg" {
  name        = "hackathon-emergency-sg-build"
  description = "Plano B - Build on Box"
  vpc_id      = "vpc-06786ee7f7a163059"

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
    from_port   = 8080
    to_port     = 8080
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

resource "aws_instance" "plan_b" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.small"
  key_name               = "hackaton-bryan"
  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.emergency_sg.id]

  tags = {
    Name = "PLAN-B-EMERGENCY-TURBO"
  }
  user_data = <<-EOF
              #!/bin/bash
        
              fallocate -l 4G /swapfile
              chmod 600 /swapfile
              mkswap /swapfile
              swapon /swapfile
              echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
              apt-get update
              apt-get install -y docker.io git curl

              # Instala Docker Compose
              curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose

              mkdir -p /app/codigos
              cd /app/codigos

              git clone https://github.com/Hackaton-Project-Devs2Blu/service-java.git java-repo
              git clone https://github.com/Hackaton-Project-Devs2Blu/service-csharp.git csharp-repo
              git clone https://github.com/Hackaton-Project-Devs2Blu/service-flutter.git flutter-repo

              cat <<EOT >> /app/codigos/docker-compose.yml
              version: '3'
              services:
                java:
                  build: ./java-repo  
                  ports:
                    - "8080:8080"
                  restart: always
                
                csharp:
                  build: ./csharp-repo 
                  ports:
                    - "5000:80"
                  restart: always

                flutter:
                  build: ./flutter-repo 
                  ports:
                    - "80:80"
                  restart: always
                  depends_on:
                    - java
                    - csharp
              EOT
              docker-compose up --build -d
              EOF
}

output "public_ip" {
  value = aws_instance.plan_b.public_ip
  description = "Acesse sua aplicação aqui: http://<IP>"
}