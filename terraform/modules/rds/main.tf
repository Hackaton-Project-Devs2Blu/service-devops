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

  publicly_accessible    = false 
  skip_final_snapshot    = true  
  multi_az               = false 
  deletion_protection    = false 
}