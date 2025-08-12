# RDS module variables

variable "identifier" {
  type        = string
  description = "The name of the RDS instance"
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.identifier))
    error_message = "Identifier must start with a letter, contain only lowercase letters, numbers, and hyphens, and end with a letter or number."
  }
}

variable "database_name" {
  type        = string
  description = "The name of the database to create when the DB instance is created"
  default     = null
  validation {
    condition     = var.database_name == null || can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", var.database_name))
    error_message = "Database name must start with a letter and contain only alphanumeric characters and underscores."
  }
}

variable "master_username" {
  type        = string
  description = "Username for the master DB user"
  default     = "postgres"
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", var.master_username))
    error_message = "Master username must start with a letter and contain only alphanumeric characters and underscores."
  }
}

variable "master_password" {
  type        = string
  description = "Password for the master DB user (managed externally)"
  sensitive   = true
}

# Network Configuration
variable "vpc_id" {
  type        = string
  description = "ID of the VPC where the DB instance will be created"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for the DB subnet group"
  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "At least 2 subnet IDs are required for high availability."
  }
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  description = "List of CIDR blocks allowed to connect to the database"
  default     = []
}

# Instance Configuration
variable "instance_class" {
  type        = string
  description = "The instance type of the RDS instance"
  default     = "db.t3.micro"
}

variable "engine_version" {
  type        = string
  description = "The engine version to use"
  default     = "15.4"
}

variable "major_engine_version" {
  type        = string
  description = "The major engine version for option group"
  default     = "15"
}

variable "parameter_group_family" {
  type        = string
  description = "The DB parameter group family"
  default     = "postgres15"
}

# Storage Configuration
variable "allocated_storage" {
  type        = number
  description = "The allocated storage in gigabytes"
  default     = 20
  validation {
    condition     = var.allocated_storage >= 20 && var.allocated_storage <= 65536
    error_message = "Allocated storage must be between 20 and 65536 GB."
  }
}

variable "max_allocated_storage" {
  type        = number
  description = "The upper limit to which Amazon RDS can automatically scale the storage"
  default     = 100
}

variable "storage_type" {
  type        = string
  description = "One of standard (magnetic), gp2 (general purpose SSD), or io1 (provisioned IOPS SSD)"
  default     = "gp2"
  validation {
    condition     = contains(["standard", "gp2", "gp3", "io1"], var.storage_type)
    error_message = "Storage type must be one of: standard, gp2, gp3, io1."
  }
}

variable "storage_encrypted" {
  type        = bool
  description = "Specifies whether the DB instance is encrypted"
  default     = true
}

variable "kms_key_id" {
  type        = string
  description = "The ARN for the KMS encryption key"
  default     = null
}

# DEPRECATED: Secrets are now managed externally by SSM module
variable "secrets_kms_key_id" {
  type        = string
  description = "The ARN for the KMS encryption key for secrets"
  default     = null
}

# High Availability
variable "multi_az" {
  type        = bool
  description = "Specifies if the RDS instance is multi-AZ"
  default     = false
}

variable "availability_zone" {
  type        = string
  description = "The AZ for the RDS instance (only used if multi_az is false)"
  default     = null
}

# Backup Configuration
variable "backup_retention_period" {
  type        = number
  description = "The days to retain backups for"
  default     = 7
  validation {
    condition     = var.backup_retention_period >= 0 && var.backup_retention_period <= 35
    error_message = "Backup retention period must be between 0 and 35 days."
  }
}

variable "backup_window" {
  type        = string
  description = "The daily time range during which automated backups are created"
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  type        = string
  description = "The window to perform maintenance in"
  default     = "sun:04:00-sun:05:00"
}

# Parameter and Option Groups
variable "create_parameter_group" {
  type        = bool
  description = "Whether to create a parameter group"
  default     = false
}

variable "parameter_group_name" {
  type        = string
  description = "Name of the DB parameter group to associate"
  default     = null
}

variable "parameters" {
  type = list(object({
    name  = string
    value = string
  }))
  description = "A list of DB parameters to apply"
  default     = []
}

variable "create_option_group" {
  type        = bool
  description = "Whether to create an option group"
  default     = false
}

variable "option_group_name" {
  type        = string
  description = "Name of the DB option group to associate"
  default     = null
}

variable "options" {
  type = list(object({
    option_name = string
    option_settings = optional(list(object({
      name  = string
      value = string
    })), [])
  }))
  description = "A list of options to apply"
  default     = []
}

# Monitoring
variable "monitoring_interval" {
  type        = number
  description = "The interval for collecting enhanced monitoring metrics"
  default     = 0
  validation {
    condition     = contains([0, 1, 5, 10, 15, 30, 60], var.monitoring_interval)
    error_message = "Monitoring interval must be one of: 0, 1, 5, 10, 15, 30, 60."
  }
}

variable "monitoring_role_arn" {
  type        = string
  description = "The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs"
  default     = null
}

variable "performance_insights_enabled" {
  type        = bool
  description = "Specifies whether Performance Insights are enabled"
  default     = false
}

variable "performance_insights_retention_period" {
  type        = number
  description = "The amount of time in days to retain Performance Insights data"
  default     = 7
  validation {
    condition     = contains([7, 31, 62, 93, 124, 155, 186, 217, 248, 279, 310, 341, 372, 403, 434, 465, 496, 527, 558, 589, 620, 651, 682, 713, 731], var.performance_insights_retention_period)
    error_message = "Performance Insights retention period must be a valid value (7, 31, 62, ..., 731)."
  }
}

variable "performance_insights_kms_key_id" {
  type        = string
  description = "The ARN for the KMS key to encrypt Performance Insights data"
  default     = null
}

# Logging
variable "enabled_cloudwatch_logs_exports" {
  type        = list(string)
  description = "List of log types to export to CloudWatch"
  default     = ["postgresql"]
  validation {
    condition = alltrue([
      for log_type in var.enabled_cloudwatch_logs_exports :
      contains(["postgresql", "upgrade"], log_type)
    ])
    error_message = "Log types must be from: postgresql, upgrade."
  }
}

# Maintenance
variable "auto_minor_version_upgrade" {
  type        = bool
  description = "Indicates that minor engine upgrades will be applied automatically"
  default     = true
}

variable "apply_immediately" {
  type        = bool
  description = "Specifies whether any database modifications are applied immediately"
  default     = false
}

# Protection
variable "deletion_protection" {
  type        = bool
  description = "The database can't be deleted when this value is set to true"
  default     = true
}

variable "iam_database_authentication_enabled" {
  type        = bool
  description = "Specifies whether or mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled"
  default     = false
}

# DEPRECATED: Secrets are now managed externally by SSM module
variable "secrets_resource_policy" {
  type        = string
  description = "Resource policy JSON for the Secrets Manager secret"
  default     = null
}

# Read Replica
variable "create_read_replica" {
  type        = bool
  description = "Whether to create a read replica"
  default     = false
}

variable "read_replica_instance_class" {
  type        = string
  description = "The instance class for the read replica"
  default     = null
}

variable "read_replica_monitoring_interval" {
  type        = number
  description = "The interval for collecting enhanced monitoring metrics for read replica"
  default     = 0
}

variable "read_replica_performance_insights_enabled" {
  type        = bool
  description = "Specifies whether Performance Insights are enabled for read replica"
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resource"
  default     = {}
}
