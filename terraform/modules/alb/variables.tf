variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment to deploy(dev, prod)"
  type        = string
  default     = "hackaton"
}

variable "vpc_id" {
  description = "VPC ID where ALB will be deployed"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet IDs where ALB will be deployed"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security Group ID for the ALB"
  type        = string
}