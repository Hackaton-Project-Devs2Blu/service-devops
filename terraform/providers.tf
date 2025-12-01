terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.46"
    }
  }
  required_version = "~>1.13"

  backend "s3" {
    bucket         = "hackathon-devs2blu-terraform-state-1533"
    key            = "hackathon/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "hackathon-terraform-locks"
    encrypt        = true
  }
}
provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project   = "Hackathon-Devs2Blu"
      ManagedBy = "Terraform"

    }
  }
}
