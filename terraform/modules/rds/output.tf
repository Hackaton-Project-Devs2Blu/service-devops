output "db_name" {
  description = "name of the database"
  value = aws_db_instance.main.db_name
}

output "db_host" {
  description = "O endereço DNS do banco de dados (Host)"
  value       = aws_db_instance.main.address
}

output "db_port" {
  description = "A porta do banco de dados"
  value       = aws_db_instance.main.port
}