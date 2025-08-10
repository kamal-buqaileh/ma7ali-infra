# ALB module variables

variable "name" {
  type        = string
  description = "Name of the Application Load Balancer"
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.name))
    error_message = "ALB name must contain only alphanumeric characters and hyphens."
  }
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC where the ALB will be created"
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block of the VPC for security group egress rules"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs where the ALB will be deployed (minimum 2 for high availability)"
  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "At least 2 subnet IDs are required for ALB high availability."
  }
}

variable "internal" {
  type        = bool
  description = "Whether the load balancer is internal or internet-facing"
  default     = false
}

variable "enable_deletion_protection" {
  type        = bool
  description = "Enable deletion protection for the load balancer"
  default     = false
}

variable "certificate_arn" {
  type        = string
  description = "ARN of the SSL certificate for HTTPS listener"
}

variable "ssl_policy" {
  type        = string
  description = "SSL policy for the HTTPS listener"
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
  validation {
    condition = contains([
      "ELBSecurityPolicy-TLS-1-0-2015-04",
      "ELBSecurityPolicy-TLS-1-1-2017-01",
      "ELBSecurityPolicy-TLS-1-2-2017-01",
      "ELBSecurityPolicy-TLS-1-2-Ext-2018-06",
      "ELBSecurityPolicy-FS-2018-06",
      "ELBSecurityPolicy-FS-1-1-2019-08",
      "ELBSecurityPolicy-FS-1-2-2019-08",
      "ELBSecurityPolicy-FS-1-2-Res-2019-08",
      "ELBSecurityPolicy-2016-08",
      "ELBSecurityPolicy-FS-1-2-Res-2020-10"
    ], var.ssl_policy)
    error_message = "SSL policy must be a valid AWS ELB security policy."
  }
}

variable "health_check_path" {
  type        = string
  description = "Health check path for the default target group"
  default     = "/health"
}

variable "access_logs_enabled" {
  type        = bool
  description = "Enable access logs for the load balancer"
  default     = false
}

variable "access_logs_bucket" {
  type        = string
  description = "S3 bucket name for access logs (required if access_logs_enabled is true)"
  default     = null
}

variable "access_logs_prefix" {
  type        = string
  description = "S3 prefix for access logs"
  default     = "alb-access-logs"
}

variable "target_groups" {
  type = map(object({
    port                    = number
    protocol                = string
    priority                = number
    host_headers            = list(string)
    health_check_enabled    = optional(bool, true)
    health_check_path       = optional(string, "/health")
    health_check_port       = optional(string, "traffic-port")
    health_check_protocol   = optional(string, "HTTP")
    healthy_threshold       = optional(number, 2)
    unhealthy_threshold     = optional(number, 2)
    timeout                 = optional(number, 5)
    interval                = optional(number, 30)
    matcher                 = optional(string, "200")
  }))
  description = "Map of additional target groups to create"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to ALB resources"
  default     = {}
}
