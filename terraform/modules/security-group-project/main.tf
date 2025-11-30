resource "aws_security_group" "project_sg" {

  name        = var.name_sg
  description = "Security group for ecs-project"
  vpc_id      = var.vpc_id

  tags = {
    Name = var.name_sg
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_lb_to_project" {
  security_group_id            = aws_security_group.project_sg.id
  referenced_security_group_id = var.security_group_id_lb
  from_port                    = 8080
  to_port                      = 8080
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.project_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}