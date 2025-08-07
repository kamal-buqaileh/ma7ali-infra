# cloudwatch module variables

variable "name" {
  type        = string
  description = "Name prefix for CloudWatch resources"
  
  validation {
    condition = can(regex("^[a-z0-9-]+$", var.name))
    error_message = "CloudWatch name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC for flow logs"
  default     = null
}

variable "log_groups" {
  type = map(object({
    name              = string
    retention_in_days = number
    tags              = map(string)
  }))
  description = "Map of CloudWatch log groups to create"
  default     = {}
}

variable "enable_vpc_flow_logs" {
  type        = bool
  description = "Whether to enable VPC flow logs"
  default     = false
}

variable "flow_log_retention_days" {
  type        = number
  description = "Retention period for VPC flow logs in days"
  default     = 7
}

variable "flow_log_iam_role_arn" {
  type        = string
  description = "The ARN of the IAM role for VPC flow logs"
  default     = null
}

variable "kms_key_id" {
  type        = string
  description = "The KMS key ID to use for encrypting CloudWatch log groups"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all CloudWatch resources"
  default     = {}
}
