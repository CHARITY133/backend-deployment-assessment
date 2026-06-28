output "vpc_id" {
  description = "VPC ID"

  value = aws_vpc.startuptech_vpc.id
}

output "alb_dns_name" {
  description = "ALB DNS Name"

  value = aws_lb.backend_alb.dns_name
}

output "bastion_public_ip" {
  description = "Bastion Public IP"

  value = aws_instance.bastion.public_ip
}

output "backend_private_ip" {
  description = "Backend Private IP"

  value = aws_instance.backend.private_ip
}