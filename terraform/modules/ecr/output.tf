output "repository_urls" {
  description = "Map with the names and URLs of the created repositories"
  value       = { for k, v in aws_ecr_repository.repositorys : k => v.repository_url }
}