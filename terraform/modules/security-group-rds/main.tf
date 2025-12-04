resource "aws_security_group" "security_group_rds" {
  name        = "${var.project_name}-rds-sg-${var.environment}"
  description = "Security Group isolado para o RDS Postgres"
  vpc_id      = var.vpc_id
  
  tags = {
    Name        = "${var.project_name}-rds-sg-${var.environment}"
    Environment = "Prod"
  }
}
resource "aws_vpc_security_group_ingress_rule" "allow_ecs_to_rds" {
  description                  = "Libera acesso do ECS (Java/C#) ao Banco de Dados"
  security_group_id            = aws_security_group.security_group_rds.id 
  referenced_security_group_id = var.security_group_id_ecs            
  from_port   = 5432
  to_port     = 5432
  ip_protocol = "tcp"
}
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.security_group_rds.id
  cidr_ipv4   = "0.0.0.0/0"
  description = "Permite saida irrestrita para atualizacoes e comunicacao interna"
  ip_protocol = "-1"
}