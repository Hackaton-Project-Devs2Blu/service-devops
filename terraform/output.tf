# Output variables for VPC module
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "VPC CIDR Block"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnets" {
  description = "Public Subnets IDs (For Load Balancer and ECS)"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "Private Subnets IDs (For RDS)"
  value       = module.vpc.private_subnets
}

output "url_aplicacao" {
  description = "Acesse a aplicação aqui (Load Balancer) "
  value       = "http://${module.alb.dns_name}"
}