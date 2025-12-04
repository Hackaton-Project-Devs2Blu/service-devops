resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster-${var.environment}"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = {
    Name        = "${var.project_name}-cluster-${var.environment}"
    Environment = "Prod"
  }
}

resource "aws_iam_role" "execution_role" {
  name = "${var.project_name}-exec-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "execution_role_policy" {
  role       = aws_iam_role.execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_cloudwatch_log_group" "logs" {
  for_each          = toset(["java", "csharp", "flutter"])
  name              = "/ecs/${var.project_name}-${each.key}-${var.environment}"
  retention_in_days = 1
  tags = {
    Name        = "${var.project_name}-cluster-${var.environment}"
    Environment = "Prod"
  }
}

resource "aws_ecs_task_definition" "java" {
  family                   = "java-task-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.execution_role.arn
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64" 
  }
  container_definitions = jsonencode([{
    name         = "java-container"
    image        = "${var.ecr_repo_urls["service-java"]}:latest"
    environment = [
        { name = "DB_HOST",     value = var.db_host }, 
        { name = "DB_NAME",     value = var.db_name },
        { name = "DB_USER",     value = var.db_username },
        { name = "DB_PASSWORD", value = var.db_password }
      ]
    essential    = true
    portMappings = [{ containerPort = 8080, hostPort = 8080 }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/${var.project_name}-java-${var.environment}"
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])
  tags = {
    Name        = "${var.project_name}-container-java-${var.environment}"
    Environment = "Prod"
  }
}

resource "aws_ecs_service" "java" {
  name            = "service-java"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.java.arn
  desired_count   = 1
  
  capacity_provider_strategy {
    base              = 0
    weight            = 100
    capacity_provider = "FARGATE_SPOT"
  }

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  network_configuration {
    subnets          = var.public_subnets
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.target_group_java_arn
    container_name   = "java-container"
    container_port   = 8080
  }
  health_check_grace_period_seconds = 120
  lifecycle {
    ignore_changes = [
      task_definition, 
      desired_count    
    ]
  }
   tags = {
    Name        = "${var.project_name}-service-java-${var.environment}"
    Environment = "Prod"
  }
}

resource "aws_appautoscaling_target" "java_target" {
  max_capacity       = 5  
  min_capacity       = 1  
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.java.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  tags = {
    Name        = "${var.project_name}-asg-java-${var.environment}"
    Environment = "Prod"
  }
}

resource "aws_appautoscaling_policy" "java_cpu_policy" {
  name               = "java-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.java_target.resource_id
  scalable_dimension = aws_appautoscaling_target.java_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.java_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = 70.0 
    scale_in_cooldown  = 60   
    scale_out_cooldown = 60   
  }
}

resource "aws_ecs_task_definition" "csharp" {
  family                   = "csharp-task-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.execution_role.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64" 
  }

  container_definitions = jsonencode([{
    name         = "csharp-container"
    image        = "${var.ecr_repo_urls["service-csharp"]}:latest"
    environment = [
        { name = "DB_HOST",     value = var.db_host }, 
        { name = "DB_NAME",     value = var.db_name },
        { name = "DB_USER",     value = var.db_username },
        { name = "DB_PASSWORD", value = var.db_password }, 
        { name = "GEMINI_API_KEY", value = var.gemini_api_key }
      ]
    essential    = true
    portMappings = [{ containerPort = 8080, hostPort = 8080 }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/${var.project_name}-csharp-${var.environment}"
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])
  tags = {
    Name        = "${var.project_name}-container-csharp-${var.environment}"
    Environment = "Prod"
  }
}

resource "aws_ecs_service" "csharp" {
  name            = "service-csharp"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.csharp.arn
  desired_count   = 1

  capacity_provider_strategy {
    base              = 0
    weight            = 100
    capacity_provider = "FARGATE_SPOT"
  }

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  network_configuration {
    subnets          = var.public_subnets
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.target_group_csharp_arn
    container_name   = "csharp-container"
    container_port   = 8080
  }

  lifecycle {
    ignore_changes = [
      task_definition, 
      desired_count    
    ]
  }
  tags = {
    Name        = "${var.project_name}-service-csharp-${var.environment}"
    Environment = "Prod"
  }
}

resource "aws_appautoscaling_target" "csharp_target" {
  max_capacity       = 5  
  min_capacity       = 1  
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.csharp.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  tags = {
    Name        = "${var.project_name}-asg-csharp-${var.environment}"
    Environment = "Prod"
  }
}

resource "aws_appautoscaling_policy" "csharp_cpu_policy" {
  name               = "csharp-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.csharp_target.resource_id
  scalable_dimension = aws_appautoscaling_target.csharp_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.csharp_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = 70.0 
    scale_in_cooldown  = 60   
    scale_out_cooldown = 60   
  }
}

resource "aws_ecs_task_definition" "flutter" {
  family                   = "flutter-task-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.execution_role.arn
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64" 
  }
  container_definitions = jsonencode([{
    name         = "flutter-container"
    image        = "${var.ecr_repo_urls["app-flutter"]}:latest"
    essential    = true
    portMappings = [{ containerPort = 80, hostPort = 80 }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/${var.project_name}-flutter-${var.environment}"
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
      }
      }
    }])
  tags = {
    Name        = "${var.project_name}-task-flutter-${var.environment}"
    Environment = "Prod"
  }
}

resource "aws_ecs_service" "flutter" {
  name            = "app-flutter"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.flutter.arn
  desired_count   = 1

  capacity_provider_strategy {
    base              = 0
    weight            = 100
    capacity_provider = "FARGATE_SPOT"
  }

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  network_configuration {
    subnets          = var.public_subnets
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.target_group_flutter_arn
    container_name   = "flutter-container"
    container_port   = 80
  }

  lifecycle {
    ignore_changes = [
      task_definition, 
      desired_count    
    ]
  }
  tags = {
    Name        = "${var.project_name}-app-flutter-${var.environment}"
    Environment = "Prod"
  }
}

resource "aws_appautoscaling_target" "flutter_target" {
  max_capacity       = 5  
  min_capacity       = 1  
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.flutter.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  tags = {
    Name        = "${var.project_name}-asg-flutter-${var.environment}"
    Environment = "Prod"
  }
}

resource "aws_appautoscaling_policy" "flutter_cpu_policy" {
  name               = "flutter-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.flutter_target.resource_id
  scalable_dimension = aws_appautoscaling_target.flutter_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.flutter_target.service_namespace
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = 70.0 
    scale_in_cooldown  = 60   
    scale_out_cooldown = 60   
  }
}