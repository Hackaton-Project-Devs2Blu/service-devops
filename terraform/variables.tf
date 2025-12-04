# Default Variables
variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
}
variable "environment" {
  description = "Environment for deployment (dev, prod)"
  type        = string
  default     = "Hackaton"
}

# Security Group Variables
variable "sg_lb_name" {
  description = "Name for the load balancer security group"
  type        = string
}
variable "sg_ecs_name" {
  description = "Name for the application security group"
  type        = string
}

# VPC Variables
variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

# ECR Variables
variable "repository_names" {
  description = "List of ECR repository names to create"
  type        = list(string)
}

# Load Balancer Variables
variable "project_name" {
  description = "Name for the Project"
  type        = string
}

# RDS Variables
variable "db_name" {
  description = "The name of the database to create"
  type        = string
}
variable "db_username" {
  description = "The username for the database"
  type        = string
}
variable "db_password" {
  description = "The password for the database"
  type        = string
}
variable "db_host" {
  description = "The database host"
  type        = string
  sensitive   = true
}