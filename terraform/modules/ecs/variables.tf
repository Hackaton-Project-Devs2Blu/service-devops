variable "project_name" {
  description = "Name for the Ecs"
  type        = string
}

variable "environment" {
  description = "Environment for the Ecs"
  type        = string
}

variable "aws_region" {
  description = "AWS region for the Ecs"
  type        = string
}

variable "public_subnets" {
  description = "subnets list for the ECS tasks"
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "ID of the Security Group for the containers"
  type        = string
}

variable "ecr_repo_urls" {
  description = "Map with the URLs of the ECR repositories (output of the ECR module)"
  type        = map(string)
}

# Target Groups vindos do Load Balancer

variable "target_group_java_arn" {
  description = "ARN of the target group for Java services"
  type        = string
}

variable "target_group_csharp_arn" {
  description = "ARN of the target group for C# services"
  type        = string
}

variable "target_group_flutter_arn" {
  description = "ARN of the target group for Flutter services"
  type        = string
}
variable "db_host" {
  description = "Database host"
  sensitive = true
  type        = string
}
variable "db_name" {
  description = "Database name"
  sensitive = true
  type        = string
}
variable "db_username" {
  description = "Database username"
  sensitive = true
  type        = string
}
variable "db_password" {
  description = "Database password"
  sensitive = true
  type        = string
}
variable "gemini_api_key" {
  description = "Chave da API do Google Gemini"
  type        = string
  sensitive   = true
}