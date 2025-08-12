# ECS Cluster module
# This module creates an ECS cluster with task definitions and services
# EC2 capacity is managed by the separate ecs_ec2 module

# CloudWatch Log Group for ECS
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/aws/ecs/${var.cluster_name}"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_arn

  tags = var.tags
}

# ECS Cluster
resource "aws_ecs_cluster" "this" {
  name = var.cluster_name

  configuration {
    execute_command_configuration {
      kms_key_id = var.kms_key_arn
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.ecs.name
      }
    }
  }

  # Enable container insights for monitoring
  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }

  tags = var.tags
}

# ECS Cluster Capacity Providers
resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = var.capacity_providers

  dynamic "default_capacity_provider_strategy" {
    for_each = var.default_capacity_provider_strategy
    content {
      capacity_provider = default_capacity_provider_strategy.value.capacity_provider
      weight           = default_capacity_provider_strategy.value.weight
      base            = lookup(default_capacity_provider_strategy.value, "base", null)
    }
  }
}

# ECS Task Definitions
resource "aws_ecs_task_definition" "this" {
  for_each = var.task_definitions

  family                   = each.value.family
  network_mode            = each.value.network_mode
  requires_compatibilities = each.value.requires_compatibilities
  cpu                     = each.value.cpu
  memory                  = each.value.memory
  execution_role_arn      = each.value.execution_role_arn
  task_role_arn          = each.value.task_role_arn

  container_definitions = jsonencode(each.value.container_definitions)

  dynamic "volume" {
    for_each = lookup(each.value, "volumes", [])
    content {
      name      = volume.value.name
      host_path = lookup(volume.value, "host_path", null)

      dynamic "efs_volume_configuration" {
        for_each = lookup(volume.value, "efs_volume_configuration", null) != null ? [volume.value.efs_volume_configuration] : []
        content {
          file_system_id          = efs_volume_configuration.value.file_system_id
          root_directory          = lookup(efs_volume_configuration.value, "root_directory", "/")
          transit_encryption      = lookup(efs_volume_configuration.value, "transit_encryption", "ENABLED")
          transit_encryption_port = lookup(efs_volume_configuration.value, "transit_encryption_port", null)

          dynamic "authorization_config" {
            for_each = lookup(efs_volume_configuration.value, "authorization_config", null) != null ? [efs_volume_configuration.value.authorization_config] : []
            content {
              access_point_id = lookup(authorization_config.value, "access_point_id", null)
              iam            = lookup(authorization_config.value, "iam", "ENABLED")
            }
          }
        }
      }
    }
  }

  tags = var.tags
}

# ECS Services
resource "aws_ecs_service" "this" {
  for_each = var.services

  name            = each.value.name
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this[each.value.task_definition_key].arn
  desired_count   = each.value.desired_count
  launch_type     = lookup(each.value, "launch_type", "EC2")

  # Service deployment configuration
  deployment_maximum_percent         = lookup(each.value, "deployment_maximum_percent", 200)
  deployment_minimum_healthy_percent = lookup(each.value, "deployment_minimum_healthy_percent", 50)

  # Load balancer configuration
  dynamic "load_balancer" {
    for_each = lookup(each.value, "load_balancers", [])
    content {
      target_group_arn = load_balancer.value.target_group_arn
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
    }
  }

  # Network configuration (for Fargate or awsvpc network mode)
  dynamic "network_configuration" {
    for_each = lookup(each.value, "network_configuration", null) != null ? [each.value.network_configuration] : []
    content {
      subnets          = network_configuration.value.subnets
      security_groups  = lookup(network_configuration.value, "security_groups", [])
      assign_public_ip = lookup(network_configuration.value, "assign_public_ip", false)
    }
  }

  # Service discovery
  dynamic "service_registries" {
    for_each = lookup(each.value, "service_registries", [])
    content {
      registry_arn   = service_registries.value.registry_arn
      container_name = lookup(service_registries.value, "container_name", null)
      container_port = lookup(service_registries.value, "container_port", null)
    }
  }

  # Capacity provider strategy
  dynamic "capacity_provider_strategy" {
    for_each = lookup(each.value, "capacity_provider_strategy", [])
    content {
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight           = capacity_provider_strategy.value.weight
      base            = lookup(capacity_provider_strategy.value, "base", null)
    }
  }

  # Auto scaling
  lifecycle {
    ignore_changes = [desired_count]
  }

  tags = var.tags

  depends_on = [aws_ecs_cluster_capacity_providers.this]
}