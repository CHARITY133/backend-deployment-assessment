# Much Todo Backend Deployment

## Overview
This project deploys a Go backend application with MongoDB on AWS using Terraform and Docker.

## Infrastructure
- VPC with public and private subnets
- Bastion host for secure SSH access
- Backend server in private subnet
- MongoDB server in private subnet
- Application Load Balancer for public access

## Deployment
1. Configure terraform.tfvars with your values
2. Run `terraform init && terraform apply`
3. SSH into backend via bastion and run `docker compose up -d`

## API
Health check: `GET /health`
