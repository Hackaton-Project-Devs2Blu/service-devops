module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.16.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs = ["${var.aws_region}a", "${var.aws_region}b"]

  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.10.0/24", "10.0.20.0/24"]

  enable_nat_gateway = false
  single_nat_gateway = false
  enable_vpn_gateway = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Environment = "Prod"
    Project     = "Infra-Platform"
  }
}

module "security_group_lb" {
  source = "./modules/security-group-lb"

  aws_region = var.aws_region
  vpc_id     = module.vpc.vpc_id
  name_sg    = var.sg_lb_name
}

module "security_group_ecs" {
  source = "./modules/security-group-project"

  aws_region           = var.aws_region
  vpc_id               = module.vpc.vpc_id
  name_sg              = var.sg_ecs_name
  security_group_id_lb = module.security_group_lb.security_group_id
}

module "alb" {
  source = "./modules/alb"

  vpc_id            = module.vpc.vpc_id
  security_group_id = module.security_group_lb.security_group_id
  public_subnets    = module.vpc.public_subnets
  project_name      = var.project_name
  environment       = var.environment
}

module "ecr" {
  source = "./modules/ecr"

  repository_names = var.repository_names
  environment      = var.environment
}

module "ecs" {
  source = "./modules/ecs"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region

  public_subnets        = module.vpc.public_subnets
  ecs_security_group_id = module.security_group_ecs.security_group_id_ecs

  ecr_repo_urls = module.ecr.repository_urls

  target_group_java_arn    = module.alb.target_group_java_arn
  target_group_csharp_arn  = module.alb.target_group_csharp_arn
  target_group_flutter_arn = module.alb.target_group_flutter_arn
}