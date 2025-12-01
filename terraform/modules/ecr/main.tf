resource "aws_ecr_repository" "repositorys" {
  for_each = toset(var.repository_names)

  name                 = "${each.key}-${var.environment}"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${each.key}-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_ecr_lifecycle_policy" "cleanup" {
  for_each = toset(var.repository_names)

  repository = aws_ecr_repository.repositorys[each.key].name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Let the last 5 images live"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 5
      }
      action = {
        type = "expire"
      }
    }]
  })
}