# ECS module variables
# This module focuses on ECS cluster, task definitions, and services
# EC2 capacity is managed by the separate ecs_ec2 module

variable "cluster_name" {
  type        = string
  description = "Name of the ECS cluster"
  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]+$", var.cluster_name))
    error_message = "Cluster name must contain only alphanumeric characters, hyphens, and underscores."
  }
}

# Logging Configuration
variable "log_retention_days" {
  type        = number
  description = "Number of days to retain CloudWatch logs"
  default     = 14
  validation {
    condition     = var.log_retention_days > 0
    error_message = "Log retention days must be greater than 0."
  }
}

variable "kms_key_arn" {
  type        = string
  description = "ARN of the KMS key for encrypting logs and EBS volumes"
}

variable "enable_container_insights" {
  type        = bool
  description = "Enable CloudWatch Container Insights for the cluster"
  default     = true
}

# Capacity Providers
variable "capacity_providers" {
  type        = list(string)
  description = "List of capacity providers for the cluster"
  default     = ["FARGATE", "FARGATE_SPOT"]
}

variable "default_capacity_provider_strategy" {
  type = list(object({
    capacity_provider = string
    weight           = number
    base            = optional(number)
  }))
  description = "Default capacity provider strategy for the cluster"
  default = [
    {
      capacity_provider = "FARGATE_SPOT"
      weight           = 1
    }
  ]
}

# Task Definitions
variable "task_definitions" {
  type        = any
  description = "Map of task definitions to create"
  default     = {}
}

# Services
variable "services" {
  type        = any
  description = "Map of ECS services to create"
  default     = {}
}

# Tags
variable "tags" {
  type        = map(string)
  description = "Tags to apply to all ECS resources"
  default     = {}
}