variable "aws_region" {
  description = "AWS Region to create infrastructure"
  type        = string
}

variable "name_sg" {
  description = "Name for the security group"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where the security group will be created"
  type        = string
}

