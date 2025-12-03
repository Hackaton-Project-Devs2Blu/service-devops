resource "aws_db_instance" "main" {
  identifier        = "${var.project_name}-db-${var.environment}"
  engine            = "postgres"
  engine_version    = "16"    
  instance_class    = "db.t4g.micro" 
  allocated_storage = 20      
  storage_type      = "gp3"   
  
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = 5432

  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids
  # nosemgrep: terraform.aws.security.aws-db-instance-no-logging.aws-db-instance-no-logging

  storage_encrypted           = true 
  auto_minor_version_upgrade  = true  
  copy_tags_to_snapshot       = true  
  publicly_accessible         = false
  
  # checkov:skip=CKV_AWS_157: "Multi-AZ custa o dobro. Hackathon requer baixo custo."
  multi_az = false 

  # checkov:skip=CKV_AWS_60: "Deletion Protection atrapalha o 'terraform destroy' rápido do Hackathon."
  deletion_protection = false 

  # checkov:skip=CKV_AWS_161: "IAM Auth aumenta complexidade do código C#/Java desnecessariamente para o MVP."
  iam_database_authentication_enabled = false

  # checkov:skip=CKV_AWS_118: "Enhanced Monitoring gera custos extras de CloudWatch."
  monitoring_interval = 0

  # checkov:skip=CKV_AWS_129: "Logs de exportação geram custos de ingestão no CloudWatch."
  # checkov:skip=CKV_AWS_354: "Performance Insights gera custos extras."
  performance_insights_enabled = false

  skip_final_snapshot = true  
}