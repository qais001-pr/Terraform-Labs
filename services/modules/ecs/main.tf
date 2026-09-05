# ============================================
# ECS CLUSTER
# ============================================
resource "aws_ecs_cluster" "main" {
  name = "${var.cluster_name}-${var.environment}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Environment = var.environment
    Terraform   = "true"
    Project     = var.project_name
  }
}

# ============================================
# CLOUDWATCH LOG GROUP (For container logs)
# ============================================
resource "aws_cloudwatch_log_group" "ecs" {
  name = "/ecs/${var.task_family}-${var.environment}"

  retention_in_days = var.log_retention_days

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

# ============================================
# IAM ROLE FOR ECS TASK EXECUTION
# ============================================
resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.task_family}-${var.environment}-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

# Attach required policies
resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Optional: Allow ECS to pull from ECR
resource "aws_iam_role_policy_attachment" "ecr_pull" {
  count = var.ecr_pull_required ? 1 : 0

  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# ============================================
# ECS TASK DEFINITION
# ============================================
resource "aws_ecs_task_definition" "main" {
  family                   = "${var.task_family}-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name  = var.task_family
      image = var.container_image
      
      portMappings = [
        for port in var.container_ports : {
          containerPort = port
          protocol      = "tcp"
        }
      ]

      environment = [
        for key, value in var.environment_variables : {
          name  = key
          value = value
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

# ============================================
# ECS SERVICE
# ============================================
resource "aws_ecs_service" "main" {
  name            = "${var.task_family}-${var.environment}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"
  platform_version = var.platform_version

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = var.assign_public_ip
  }

  # Load Balancer Configuration (if needed)
  dynamic "load_balancer" {
    for_each = var.load_balancer_config != null ? [var.load_balancer_config] : []
    content {
      target_group_arn = load_balancer.value.target_group_arn
      container_name   = var.task_family
      container_port   = load_balancer.value.container_port
    }
  }

  # Service Discovery (if enabled)
  dynamic "service_registries" {
    for_each = var.enable_service_discovery ? [1] : []
    content {
      registry_arn = aws_service_discovery_service.ecs[0].arn
    }
  }

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }

  depends_on = [
    aws_iam_role_policy_attachment.ecs_task_execution,
    aws_iam_role_policy_attachment.ecr_pull
  ]

  # Ignore changes to desired_count (to allow autoscaling)
  lifecycle {
    ignore_changes = [
      desired_count,
      task_definition
    ]
  }
}

# ============================================
# SERVICE DISCOVERY (Optional)
# ============================================
resource "aws_service_discovery_private_dns_namespace" "main" {
  count = var.enable_service_discovery ? 1 : 0

  name        = "${var.environment}.${var.service_discovery_namespace}"
  description = "Service discovery namespace for ${var.environment}"
  vpc         = var.vpc_id
}

resource "aws_service_discovery_service" "ecs" {
  count = var.enable_service_discovery ? 1 : 0

  name = "${var.task_family}-${var.environment}"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main[0].id

    dns_records {
      ttl  = 60
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    # failure_threshold = 1
  }
}

# ============================================
# AUTO SCALING (Optional)
# ============================================
resource "aws_appautoscaling_target" "ecs" {
  count = var.enable_autoscaling ? 1 : 0

  max_capacity       = var.autoscaling_max_capacity
  min_capacity       = var.autoscaling_min_capacity
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_cpu" {
  count = var.enable_autoscaling ? 1 : 0

  name               = "${var.task_family}-${var.environment}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs[0].service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = var.autoscaling_cpu_target

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}