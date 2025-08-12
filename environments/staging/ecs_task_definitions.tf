# ECS Task Definitions for ma7ali applications
# Defines container specifications, resource requirements, and configurations

# Local values for common task definition settings
locals {
  # Common environment variables for all services
  common_environment = [
    {
      name  = "NODE_ENV"
      value = var.environment
    },
    {
      name  = "AWS_REGION"
      value = var.aws_region
    }
  ]

  # Common log configuration
  common_log_configuration = {
    logDriver = "awslogs"
    options = {
      "awslogs-group"         = "/aws/ecs/${var.project_name}-${var.environment}-cluster"
      "awslogs-region"        = var.aws_region
      "awslogs-stream-prefix" = "ecs"
    }
  }

  # Domain configurations
  api_url   = "https://api.${var.is_production ? var.domain_name : "${var.environment}.${var.domain_name}"}"
  admin_url = "https://admin.${var.is_production ? var.domain_name : "${var.environment}.${var.domain_name}"}"
}

# Task Definitions Map for ECS Module
locals {
  task_definitions = {
    frontend = {
      family                   = "${var.project_name}-${var.environment}-frontend"
      network_mode             = "bridge"
      requires_compatibilities = ["EC2", "FARGATE"]
      cpu                      = "256"
      memory                   = "512"
      execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
      task_role_arn            = aws_iam_role.ecs_task_role.arn

      container_definitions = [
        {
          name      = "frontend"
          image     = "${module.ecr.repository_urls["frontend"]}:latest"
          memory    = 512
          essential = true

          portMappings = [
            {
              containerPort = 3000
              protocol      = "tcp"
            }
          ]

          environment = concat(local.common_environment, [
            {
              name  = "PORT"
              value = "3000"
            },
            {
              name  = "API_URL"
              value = local.api_url
            }
          ])

          logConfiguration = merge(local.common_log_configuration, {
            options = merge(local.common_log_configuration.options, {
              "awslogs-stream-prefix" = "frontend"
            })
          })

          healthCheck = {
            command     = ["CMD-SHELL", "curl -f http://localhost:3000/health || exit 1"]
            interval    = 30
            timeout     = 5
            retries     = 3
            startPeriod = 60
          }
        }
      ]
    }

    backend = {
      family                   = "${var.project_name}-${var.environment}-backend"
      network_mode             = "bridge"
      requires_compatibilities = ["EC2", "FARGATE"]
      cpu                      = "512"
      memory                   = "1024"
      execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
      task_role_arn            = aws_iam_role.ecs_task_role.arn

      container_definitions = [
        {
          name      = "backend"
          image     = "${module.ecr.repository_urls["backend"]}:latest"
          memory    = 1024
          essential = true

          portMappings = [
            {
              containerPort = 8000
              protocol      = "tcp"
            }
          ]

          environment = concat(local.common_environment, [
            {
              name  = "PORT"
              value = "8000"
            }
          ])

          secrets = [
            {
              name      = "DATABASE_URL"
              valueFrom = "${module.ssm.secret_arns["database_credentials"]}:database_url::"
            }
          ]

          logConfiguration = merge(local.common_log_configuration, {
            options = merge(local.common_log_configuration.options, {
              "awslogs-stream-prefix" = "backend"
            })
          })

          healthCheck = {
            command     = ["CMD-SHELL", "curl -f http://localhost:8000/api/health || exit 1"]
            interval    = 30
            timeout     = 5
            retries     = 3
            startPeriod = 120
          }
        }
      ]
    }

    admin = {
      family                   = "${var.project_name}-${var.environment}-admin"
      network_mode             = "bridge"
      requires_compatibilities = ["EC2", "FARGATE"]
      cpu                      = "256"
      memory                   = "512"
      execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
      task_role_arn            = aws_iam_role.ecs_task_role.arn

      container_definitions = [
        {
          name      = "admin"
          image     = "${module.ecr.repository_urls["frontend"]}:latest" # Reuse frontend image
          memory    = 512
          essential = true

          portMappings = [
            {
              containerPort = 3001
              protocol      = "tcp"
            }
          ]

          environment = concat(local.common_environment, [
            {
              name  = "PORT"
              value = "3001"
            },
            {
              name  = "ADMIN_MODE"
              value = "true"
            },
            {
              name  = "API_URL"
              value = local.api_url
            }
          ])

          logConfiguration = merge(local.common_log_configuration, {
            options = merge(local.common_log_configuration.options, {
              "awslogs-stream-prefix" = "admin"
            })
          })

          healthCheck = {
            command     = ["CMD-SHELL", "curl -f http://localhost:3001/admin/health || exit 1"]
            interval    = 30
            timeout     = 5
            retries     = 3
            startPeriod = 60
          }
        }
      ]
    }
  }

  # ECS Services Configuration
  services = {
    frontend = {
      name                = "${var.project_name}-${var.environment}-frontend"
      task_definition_key = "frontend"
      desired_count       = 1
      launch_type         = "EC2"

      deployment_maximum_percent         = 200
      deployment_minimum_healthy_percent = 50

      load_balancers = [
        {
          target_group_arn = module.alb.target_group_arns["app"]
          container_name   = "frontend"
          container_port   = 3000
        }
      ]

      capacity_provider_strategy = [
        {
          capacity_provider = "${var.project_name}-${var.environment}-cluster-ec2"
          weight            = 1
        }
      ]
    }

    backend = {
      name                = "${var.project_name}-${var.environment}-backend"
      task_definition_key = "backend"
      desired_count       = 1
      launch_type         = "EC2"

      deployment_maximum_percent         = 200
      deployment_minimum_healthy_percent = 50

      load_balancers = [
        {
          target_group_arn = module.alb.target_group_arns["api"]
          container_name   = "backend"
          container_port   = 8000
        }
      ]

      capacity_provider_strategy = [
        {
          capacity_provider = "${var.project_name}-${var.environment}-cluster-ec2"
          weight            = 1
        }
      ]
    }

    admin = {
      name                = "${var.project_name}-${var.environment}-admin"
      task_definition_key = "admin"
      desired_count       = 1
      launch_type         = "EC2"

      deployment_maximum_percent         = 200
      deployment_minimum_healthy_percent = 50

      load_balancers = [
        {
          target_group_arn = module.alb.target_group_arns["admin"]
          container_name   = "admin"
          container_port   = 3001
        }
      ]

      capacity_provider_strategy = [
        {
          capacity_provider = "${var.project_name}-${var.environment}-cluster-ec2"
          weight            = 1
        }
      ]
    }
  }
}
