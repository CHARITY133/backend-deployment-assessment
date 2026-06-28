variable "aws_region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "my_ip" {
  description = "Your public IP"
}

variable "key_name" {
  type        = string
  description = "Name of the existing AWS key pair to attach to EC2 instances"
  default     = "muchtodo-key"
}

variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  type        = string
  description = "CIDR block for public subnet 1"
  default     = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  type        = string
  description = "CIDR block for public subnet 2"
  default     = "10.0.2.0/24"
}

variable "private_subnet_1_cidr" {
  type        = string
  description = "CIDR block for private subnet 1"
  default     = "10.0.3.0/24"
}

variable "private_subnet_2_cidr" {
  type        = string
  description = "CIDR block for private subnet 2"
  default     = "10.0.4.0/24"
}