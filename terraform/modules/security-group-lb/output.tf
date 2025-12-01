output "security_group_id" {
  value       = aws_security_group.security_group_lb.id
  description = "Id of the security group"
}