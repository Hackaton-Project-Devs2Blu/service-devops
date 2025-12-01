output "security_group_id_ecs" {
  value       = aws_security_group.project_sg.id
  description = "Id of the security group"
}