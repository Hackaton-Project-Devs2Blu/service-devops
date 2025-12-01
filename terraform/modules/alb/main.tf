# 1. O Load Balancer em si
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.public_subnets

  enable_deletion_protection = false

  tags = {
    Name        = "${var.project_name}-alb-${var.environment}"
    Environment = var.environment
  }
}

# Grupo para o JAVA
resource "aws_lb_target_group" "java" {
  name        = "tg-java-${var.environment}"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/actuator/health"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

# Grupo para o C# (.NET)
resource "aws_lb_target_group" "csharp" {
  name        = "tg-csharp-${var.environment}"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path    = "/health"
    matcher = "200"
  }
}

# Grupo para o FLUTTER (Web)
resource "aws_lb_target_group" "flutter" {
  name        = "tg-flutter-${var.environment}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path    = "/"
    matcher = "200"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.flutter.arn
  }
}

# 4. Regras de Roteamento (Path-Based Routing)

resource "aws_lb_listener_rule" "java_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.java.arn
  }

  condition {
    path_pattern {
      values = ["/api/java/*"]
    }
  }
}

resource "aws_lb_listener_rule" "csharp_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.csharp.arn
  }

  condition {
    path_pattern {
      values = ["/api/csharp/*"]
    }
  }
}