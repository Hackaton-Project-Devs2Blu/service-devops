variable "project_name" {
  type = string
  description = "name of the database project"
}
variable "environment" {
    type = string
    description = "environment of the database (e.g., dev, prod)"
}
variable "db_name" {
    type = string
    description = "Name of the initial database to create"
}
variable "db_username" {
    type = string
    description = "Username for the database"
}
variable "db_password" {
    type = string
    description = "Password for the database"
}
variable "db_subnet_group_name" {
  type        = string
  description = "Nome do grupo de subnets vindo do modulo subnet-db"
}
variable "vpc_security_group_ids" {
  type        = list(string)
  description = "Lista de SGs vindo do modulo security-group-rds"
}