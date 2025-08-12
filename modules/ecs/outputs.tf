# ECS module outputs
# This module focuses on ECS cluster, task definitions, and services
# EC2 capacity outputs are provided by the separate ecs_ec2 module

output "cluster_id" {
  description = "The ID of the ECS cluster"
  value       = aws_ecs_cluster.this.id
}

output "cluster_name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_cluster.this.name
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = aws_ecs_cluster.this.arn
}

output "cluster_capacity_providers" {
  description = "List of cluster capacity providers"
  value       = aws_ecs_cluster_capacity_providers.this.capacity_providers
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.ecs.name
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.ecs.arn
}

output "task_definition_arns" {
  description = "Map of task definition ARNs"
  value = {
    for key, task_def in aws_ecs_task_definition.this : key => task_def.arn
  }
}

output "task_definition_families" {
  description = "Map of task definition families"
  value = {
    for key, task_def in aws_ecs_task_definition.this : key => task_def.family
  }
}

output "task_definition_revisions" {
  description = "Map of task definition revisions"
  value = {
    for key, task_def in aws_ecs_task_definition.this : key => task_def.revision
  }
}

output "service_names" {
  description = "Map of ECS service names"
  value = {
    for key, service in aws_ecs_service.this : key => service.name
  }
}

output "service_arns" {
  description = "Map of ECS service ARNs"
  value = {
    for key, service in aws_ecs_service.this : key => service.id
  }
}

output "service_cluster_arns" {
  description = "Map of ECS service cluster ARNs"
  value = {
    for key, service in aws_ecs_service.this : key => service.cluster
  }
}

output "service_desired_counts" {
  description = "Map of ECS service desired counts"
  value = {
    for key, service in aws_ecs_service.this : key => service.desired_count
  }
}

output "service_launch_types" {
  description = "Map of ECS service launch types"
  value = {
    for key, service in aws_ecs_service.this : key => service.launch_type
  }
}