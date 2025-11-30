output "alb_dns_name" {
  description = "Load Balancer DNS Name"
  value       = aws_lb.main.dns_name
}

output "target_group_java_arn" {
  value = aws_lb_target_group.java.arn
}

output "target_group_csharp_arn" {
  value = aws_lb_target_group.csharp.arn
}

output "target_group_flutter_arn" {
  value = aws_lb_target_group.flutter.arn
}