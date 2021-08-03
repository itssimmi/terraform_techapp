terraform {
  required_version = ">= 0.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
    region  = "us-east-1"
    access_key = var.var_access_key
    secret_key = var.var_secret_key
}

resource "aws_vpc" "first-vpc" {
  cidr_block = var.vpc_prefix
  tags = {
    Name = "tech-vpc"
  }
}

resource "aws_internet_gateway" "ig-1" {
  vpc_id = aws_vpc.first-vpc.id
}

resource "aws_route_table" "rt-1" {
  vpc_id = aws_vpc.first-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig-1.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_internet_gateway.ig-1.id
  }
}


resource "aws_subnet" "subnet-1" {
  vpc_id = aws_vpc.first-vpc.id
  cidr_block = var.subnet_prefix
  availability_zone =  "us-east-1a"
  tags = {
    Name = "prod-subnet"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.rt-1.id
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id = aws_vpc.first-vpc.id

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTP"
    from_port        = 3000
    to_port          = 3000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_network_interface" "web-server-nic" {
  subnet_id = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_tls.id]
}

resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.ig-1]
}

resource "aws_instance" "web-server-instance" {
    ami           = "ami-09e67e426f25ce0d7" 
    instance_type = "t2.micro"
    availability_zone =  "us-east-1a"
    key_name = "main-key"
    

    network_interface {
      device_index = 0
      network_interface_id = aws_network_interface.web-server-nic.id
    }

    provisioner "file" {
      source      = "files/conf.toml"
      destination = "/home/ubuntu/conf.toml"

      connection {
        type     = "ssh"
        user     = "ubuntu"
        private_key = "${file("../new-key.pem")}"
        host     = "${self.public_ip}"
      }
    }

    user_data = "${file("user_data.sh")}"

    tags = {
      Name = "docker-test"
    }
}