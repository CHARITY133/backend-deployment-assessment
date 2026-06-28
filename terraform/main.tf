# ===== TERRAFORM BLOCK================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

#=======PROVIDER BLOCK ==========

provider "aws" {
  region = var.aws_region
}

#====== VPC =====================

resource "aws_vpc" "startuptech_vpc" {

  cidr_block = var.vpc_cidr

  enable_dns_support = true

  enable_dns_hostnames = true

  tags = {
    Name = "startuptech-vpc"
  }
}

#====== PUBLIC SUBNET 1 ======

resource "aws_subnet" "public_subnet_1" {

  vpc_id = aws_vpc.startuptech_vpc.id

  cidr_block = var.public_subnet_1_cidr

  availability_zone = "us-east-1a"

  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-1"
  }
}

#======== PUBLIC SUBNET 2 =========

resource "aws_subnet" "public_subnet_2" {

  vpc_id = aws_vpc.startuptech_vpc.id

  cidr_block = var.public_subnet_2_cidr

  availability_zone = "us-east-1b"

  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-2"
  }
}

#========PRIVATE SUBNET 1===========

resource "aws_subnet" "private_subnet_1" {

  vpc_id = aws_vpc.startuptech_vpc.id

  cidr_block = var.private_subnet_1_cidr

  availability_zone = "us-east-1a"

  tags = {
    Name = "private-subnet-1"
  }
}

#=======PRIVATE SUBNET 2=============

resource "aws_subnet" "private_subnet_2" {

  vpc_id = aws_vpc.startuptech_vpc.id

  cidr_block = var.private_subnet_2_cidr

  availability_zone = "us-east-1b"

  tags = {
    Name = "private-subnet-2"
  }
}

#======= INTERNET GATEWAY ==========

resource "aws_internet_gateway" "igw" {

  vpc_id = aws_vpc.startuptech_vpc.id

  tags = {
    Name = "startuptech-igw"
  }
}

#======== ELASTIC IP FOR NAT ========

resource "aws_eip" "nat_eip" {

  domain = "vpc"

  tags = {
    Name = "nat-eip"
  }
}

#======== NAT GATEWAY =============

resource "aws_nat_gateway" "nat_gateway" {

  allocation_id = aws_eip.nat_eip.id

  subnet_id = aws_subnet.public_subnet_1.id

  tags = {
    Name = "startuptech-nat"
  }

  depends_on = [
    aws_internet_gateway.igw
  ]
}

#======== PUBLIC ROUTE TABLE=======

resource "aws_route_table" "public_rt" {

  vpc_id = aws_vpc.startuptech_vpc.id

  route {

    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

#======= PRIVATE ROUTE TABLE========

resource "aws_route_table" "private_rt" {

  vpc_id = aws_vpc.startuptech_vpc.id

  route {

    cidr_block = "0.0.0.0/0"

    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "private-route-table"
  }
}

#======== PUBLIC SUBNET 1 ASSOCIATION========

resource "aws_route_table_association" "public_assoc_1" {

  subnet_id = aws_subnet.public_subnet_1.id

  route_table_id = aws_route_table.public_rt.id
}

#======== PUBLIC SUBNET 2 ASSOCAITION==========

resource "aws_route_table_association" "public_assoc_2" {

  subnet_id = aws_subnet.public_subnet_2.id

  route_table_id = aws_route_table.public_rt.id
}

#======== PRIVATE SUBNET 1 ASSOCIATION ========

resource "aws_route_table_association" "private_assoc_1" {

  subnet_id = aws_subnet.private_subnet_1.id

  route_table_id = aws_route_table.private_rt.id
}

#======== PRIVATE SUBNET 2 ASSOCIATION ========

resource "aws_route_table_association" "private_assoc_2" {

  subnet_id = aws_subnet.private_subnet_2.id

  route_table_id = aws_route_table.private_rt.id
}


#================= ALB SG ====================

resource "aws_security_group" "alb_sg" {

  name = "alb-sg"

  vpc_id = aws_vpc.startuptech_vpc.id

  ingress {
    from_port = 80
    to_port   = 80

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port   = 443

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }
}

#============ BASTION SG =====================

resource "aws_security_group" "bastion_sg" {

  name = "bastion-sg"

  vpc_id = aws_vpc.startuptech_vpc.id

  ingress {
    from_port = 22
    to_port   = 22

    protocol = "tcp"

    cidr_blocks = ["${var.my_ip}/32"]
  }

  egress {
    from_port = 0
    to_port   = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }
}

#============ BACKEND SG ====================


resource "aws_security_group" "backend_sg" {

  name        = "backend-sg"
  description = "Backend Server Security Group"
  vpc_id      = aws_vpc.startuptech_vpc.id

  ingress {
    description = "Backend Traffic from ALB"

    from_port = 8080
    to_port   = 8080

    protocol = "tcp"

    security_groups = [
      aws_security_group.alb_sg.id
    ]
  }

  ingress {
    description = "SSH from Bastion"

    from_port = 22
    to_port   = 22

    protocol = "tcp"

    security_groups = [
      aws_security_group.bastion_sg.id
    ]
  }

  egress {
    from_port = 0
    to_port   = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "backend-sg"
  }
}

#========= MONGODB SG =============

resource "aws_security_group" "mongodb_sg" {

  name        = "mongodb-sg"
  description = "MongoDB Security Group"
  vpc_id      = aws_vpc.startuptech_vpc.id

  ingress {
    description = "MongoDB Access from Backend"

    from_port = 27017
    to_port   = 27017

    protocol = "tcp"

    security_groups = [
      aws_security_group.backend_sg.id
    ]
  }

  ingress {
    description = "SSH from Bastion"

    from_port = 22
    to_port   = 22

    protocol = "tcp"

    security_groups = [
      aws_security_group.bastion_sg.id
    ]
  }

  egress {
    from_port = 0
    to_port   = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mongodb-sg"
  }
}


#======= FETCH AMAZON LINUX AMI=====================

data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

#======== BASTION HOST PUBLIC SERVER==================

resource "aws_instance" "bastion" {

  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.key_name

  subnet_id = aws_subnet.public_subnet_1.id

  vpc_security_group_ids = [
    aws_security_group.bastion_sg.id
  ]

  associate_public_ip_address = true

  tags = {
    Name = "bastion-host"
  }
}

#==========BACKEND SERVER PRIVATE=======================

resource "aws_instance" "backend" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.key_name

  subnet_id = aws_subnet.private_subnet_1.id

  vpc_security_group_ids = [
    aws_security_group.backend_sg.id
  ]

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  user_data = file("${path.module}/user_data/backend_setup.sh")

  tags = {
    Name = "backend-server"
  }
}


#=============MONGODB SERVER PRIVATE===================


resource "aws_instance" "mongodb" {

  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.key_name

  subnet_id = aws_subnet.private_subnet_1.id

  vpc_security_group_ids = [
    aws_security_group.mongodb_sg.id
  ]

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  user_data = file("${path.module}/user_data/mongodb_setup.sh")

  tags = {
    Name = "mongodb-server"
  }
}

#============ TARGET GROUP========================

resource "aws_lb_target_group" "backend_tg" {

  name     = "backend-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.startuptech_vpc.id

  health_check {

    path                = "/health"
    port                = "8080"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    timeout             = 5
    matcher             = "200"
  }
}

#=========== LOAD BALANCER=========================

resource "aws_lb" "backend_alb" {

  name               = "backend-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb_sg.id
  ]

  subnets = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id
  ]

  tags = {
    Name = "backend-alb"
  }
}

#============LISTERNER===========================

resource "aws_lb_listener" "http_listener" {

  load_balancer_arn = aws_lb.backend_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {

    type = "forward"

    target_group_arn = aws_lb_target_group.backend_tg.arn
  }
}

#============= ATTACHMENT ======================

resource "aws_lb_target_group_attachment" "backend_attach" {

  target_group_arn = aws_lb_target_group.backend_tg.arn

  target_id = aws_instance.backend.id

  port = 8080
}