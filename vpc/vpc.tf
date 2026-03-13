variable "aws_region" {
  type = string
}
variable "aws_access_key_id" {
  type      = string
  sensitive = true
}
variable "aws_secret_access_key" {
  type      = string
  sensitive = true
}

variable "localstack_endpoints" {
  type    = string
  default = "http://localhost:4566"
}
variable "ec2_ami" {
  type    = string
  default = "ami-04eb12fc3dd65c57a"
}
variable "ec2_instance_type" {
  type    = string
  default = "t3.micro"
}







resource "aws_vpc" "demo_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "demo-vpc"
    environment = "local-test"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.demo_vpc.id
  cidr_block = var.public_subnet_cidr_block
  availability_zone = "${var.aws_region}a"
}
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.demo_vpc.id
  cidr_block = "10.0.2.0/24"
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.demo_vpc.id
}
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.demo_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_security_group" "demo_sg" {
  name        = "demo-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.demo_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_ip]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}
}

resource "aws_instance" "demo_ec2" {
  ami                         = var.ec2_ami
  instance_type               = var.ec2_instance_type
  subnet_id                   = aws_subnet.public_subnet.id
    vpc_security_group_ids      = [aws_security_group.demo_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "demo-ec2"
  }
}
output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.demo_ec2.public_ip
}

