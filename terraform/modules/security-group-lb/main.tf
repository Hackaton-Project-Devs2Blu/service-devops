resource "aws_security_group" "security_group_lb" {

  name        = var.name_sg
  description = "Security group for Load Balancer"
  vpc_id      = var.vpc_id

  tags = {
    Name = var.name_sg
    Environment = "Prod"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ipv4_rule_https" {
  security_group_id = aws_security_group.security_group_lb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "ipv4_rule_http" {
  security_group_id = aws_security_group.security_group_lb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.security_group_lb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}