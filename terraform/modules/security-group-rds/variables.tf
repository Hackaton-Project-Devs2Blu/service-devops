variable "environment" {
    type = string
    description = "environment of the database (e.g., dev, prod)"
}
variable "project_name" {
    type = string
    description = "name of the database project"
}
variable "vpc_id" {
    type = string
    description = "VPC ID where the RDS instance will be deployed"
}
variable "security_group_id_ecs" {
  type        = string
  description = "ID do Security Group do ECS para liberar acesso"
}