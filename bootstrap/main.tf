provider "aws" {
  region = "us-west-2" 
  default_tags {
    tags = {
      Project     = "Hackathon-Devs2Blu"
      ManagedBy   = "Terraform"
      Application = "Chatbot-SEDEAD"
      Environment = "Prod"          
      Service     = "Hackathon-Platform" 
      CostCenter  = "SEDEAD-Blumenau" 
      Owner       = "Squad-Devs2Blu"  
      Team        = "DevOps-Team"     
      DataClass   = "Confidential"    
    }
  }
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "hackathon-devs2blu-terraform-state-1533" 
  force_destroy = true 
  tags = {
    Name = "Hackathon-terraform-locks"
    Environment = "Prod"
    }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encrypt" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "Hackathon-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    Name = "Hackathon-terraform-locks"
    Environment = "Prod"
    }
}

output "bucket_name" {
  value = aws_s3_bucket.terraform_state.bucket
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.terraform_locks.name
}


data "aws_caller_identity" "current" {}

resource "aws_iam_role" "github_actions" {
  name = "github-actions-oidc-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" : "repo:Hackaton-Project-Devs2Blu/*"
          }
        }
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "github_actions_admin" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
output "github_actions_role_arn" {
  value = aws_iam_role.github_actions.arn
}