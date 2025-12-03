variable "environment" {
    type = string
    description = "environment of the database (e.g., dev, prod)"
}
variable "project_name" {
    type = string
    description = "name of the database project"
}
variable "private_subnet_ids" {
    type = list(string)
    description = "List of private subnet IDs for the database subnet group"
}