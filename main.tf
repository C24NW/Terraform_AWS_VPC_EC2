#Provider and region
provider "aws" {
  region = "us-east-1"
}

#Create VPC
resource "aws_vpc" "vpc_1" {
  cidr_block = "10.0.0.0/16"
}

#Create subnet
resource "aws_subnet" "vpc1_subnet1" {
  vpc_id     = aws_vpc.vpc_1.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "vpc1_subnet1"
  }
}

#Create internet gateway
resource "aws_internet_gateway" "igw1" {
  vpc_id = aws_vpc.vpc_1.id

  tags = {
    Name = "igw1"
  }
}

#Create route table
resource "aws_route_table" "route_table1" {
  vpc_id = aws_vpc.vpc_1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw1.id
  }

  tags = {
    Name = "route_table1"
  }
}

#Create route table association with subnet
resource "aws_route_table_association" "route_table_association" {
  #Assocation subnet id with route table id
  subnet_id      = aws_subnet.vpc1_subnet1.id
  route_table_id = aws_route_table.route_table1.id
}

#Create security group
resource "aws_security_group" "security_group1" {
  name        = "security-group1"
  description = "Allow inbound ssh, http, https"
  vpc_id      = aws_vpc.vpc_1.id

  ingress {
    description = "https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["192.168.1.102/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Create EC2 instance
resource "aws_instance" "ec2_instance" {
  ami                    = "ami-05e411cf591b5c9f6"
  key_name               = "main-key"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.vpc1_subnet1.id
  vpc_security_group_ids = [aws_security_group.security_group1.id]
}

