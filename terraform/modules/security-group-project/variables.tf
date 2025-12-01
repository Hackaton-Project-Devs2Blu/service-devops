variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
}

variable "name_sg" {
  description = "Name for the security group"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the security group will be created"
  type        = string
}

variable "security_group_id_lb" {
  description = "The security group ID of the load balancer to allow ingress from"
  type        = string
}