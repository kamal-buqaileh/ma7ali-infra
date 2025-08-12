# ECS EC2 module variables

variable "cluster_name" {
  type        = string
  description = "Name of the ECS cluster"
  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]+$", var.cluster_name))
    error_message = "Cluster name must contain only alphanumeric characters, hyphens, and underscores."
  }
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC where instances will be created"
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block of the VPC for internal communication"
  validation {
    condition     = can(cidrhost(var.vpc_cidr_block, 0))
    error_message = "VPC CIDR block must be a valid CIDR."
  }
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for the Auto Scaling Group"
  validation {
    condition     = length(var.subnet_ids) >= 1
    error_message = "At least 1 subnet ID is required."
  }
}

variable "region" {
  type        = string
  description = "AWS region for resource configuration"
}

# AMI Configuration
variable "ami_id" {
  type        = string
  description = "AMI ID for ECS instances (leave empty for latest ECS-optimized AMI)"
  default     = ""
}

variable "ami_type" {
  type        = string
  description = "AMI architecture type"
  default     = "arm64"
  validation {
    condition     = contains(["arm64", "x86_64"], var.ami_type)
    error_message = "AMI type must be either 'arm64' or 'x86_64'."
  }
}

# Instance Configuration
variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t4g.micro"
  validation {
    condition = contains([
      "t3.nano", "t3.micro", "t3.small", "t3.medium", "t3.large",
      "t4g.nano", "t4g.micro", "t4g.small", "t4g.medium", "t4g.large",
      "m5.large", "m5.xlarge", "m5.2xlarge",
      "c5.large", "c5.xlarge", "c5.2xlarge"
    ], var.instance_type)
    error_message = "Instance type must be a supported ECS instance type."
  }
}

variable "key_name" {
  type        = string
  description = "EC2 Key Pair name for SSH access (optional)"
  default     = null
}

variable "instance_profile_name" {
  type        = string
  description = "IAM instance profile name for EC2 instances"
}

# Storage Configuration
variable "volume_size" {
  type        = number
  description = "Size of the EBS volume in GB"
  default     = 30
  validation {
    condition     = var.volume_size >= 8 && var.volume_size <= 1000
    error_message = "Volume size must be between 8 and 1000 GB."
  }
}

variable "volume_type" {
  type        = string
  description = "Type of EBS volume"
  default     = "gp3"
  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2"], var.volume_type)
    error_message = "Volume type must be one of: gp2, gp3, io1, io2."
  }
}

variable "kms_key_arn" {
  type        = string
  description = "ARN of the KMS key for encrypting EBS volumes"
}

# Auto Scaling Configuration
variable "min_size" {
  type        = number
  description = "Minimum number of instances in the Auto Scaling Group"
  default     = 0
  validation {
    condition     = var.min_size >= 0 && var.min_size <= 100
    error_message = "Min size must be between 0 and 100."
  }
}

variable "max_size" {
  type        = number
  description = "Maximum number of instances in the Auto Scaling Group"
  default     = 10
  validation {
    condition     = var.max_size >= 1 && var.max_size <= 1000
    error_message = "Max size must be between 1 and 1000."
  }
}

variable "desired_capacity" {
  type        = number
  description = "Desired number of instances in the Auto Scaling Group"
  default     = 1
  validation {
    condition     = var.desired_capacity >= 0 && var.desired_capacity <= 100
    error_message = "Desired capacity must be between 0 and 100."
  }
}

variable "protect_from_scale_in" {
  type        = bool
  description = "Whether to enable instance scale-in protection"
  default     = false
}

variable "health_check_grace_period" {
  type        = number
  description = "Health check grace period in seconds"
  default     = 300
  validation {
    condition     = var.health_check_grace_period >= 0 && var.health_check_grace_period <= 7200
    error_message = "Health check grace period must be between 0 and 7200 seconds."
  }
}

variable "termination_policies" {
  type        = list(string)
  description = "List of termination policies for the Auto Scaling Group"
  default     = ["Default"]
  validation {
    condition = alltrue([
      for policy in var.termination_policies : contains([
        "Default", "OldestInstance", "NewestInstance", "OldestLaunchConfiguration",
        "OldestLaunchTemplate", "ClosestToNextInstanceHour"
      ], policy)
    ])
    error_message = "Termination policies must be valid AWS Auto Scaling termination policies."
  }
}

# Capacity Provider Configuration
variable "enable_managed_scaling" {
  type        = bool
  description = "Whether to enable ECS managed scaling"
  default     = true
}

variable "target_capacity" {
  type        = number
  description = "Target capacity percentage for the capacity provider"
  default     = 80
  validation {
    condition     = var.target_capacity >= 1 && var.target_capacity <= 100
    error_message = "Target capacity must be between 1 and 100."
  }
}

variable "max_scaling_step_size" {
  type        = number
  description = "Maximum step adjustment size for scaling"
  default     = 10
  validation {
    condition     = var.max_scaling_step_size >= 1 && var.max_scaling_step_size <= 100
    error_message = "Max scaling step size must be between 1 and 100."
  }
}

variable "min_scaling_step_size" {
  type        = number
  description = "Minimum step adjustment size for scaling"
  default     = 1
  validation {
    condition     = var.min_scaling_step_size >= 1 && var.min_scaling_step_size <= 100
    error_message = "Min scaling step size must be between 1 and 100."
  }
}

# Security Configuration
variable "create_security_group" {
  type        = bool
  description = "Whether to create a security group for ECS instances"
  default     = true
}

variable "security_group_ids" {
  type        = list(string)
  description = "List of security group IDs to attach to instances"
  default     = []
}

variable "alb_security_group_ids" {
  type        = list(string)
  description = "List of ALB security group IDs that can access ECS instances"
  default     = []
}

variable "ssh_allowed_cidr_blocks" {
  type        = list(string)
  description = "List of CIDR blocks allowed for SSH access"
  default     = []
}

# Load Balancer Configuration
variable "target_group_arns" {
  type        = list(string)
  description = "List of target group ARNs to attach to the Auto Scaling Group"
  default     = []
}

# Tags
variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}
