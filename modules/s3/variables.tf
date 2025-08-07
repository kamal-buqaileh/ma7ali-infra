variable "bucket_prefix" {
  description = "Prefix for the S3 bucket name"
  type        = string
  
  validation {
    condition = can(regex("^[a-z0-9-]+$", var.bucket_prefix))
    error_message = "Bucket prefix must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment name (e.g. staging, production)"
  type        = string
}

variable "acl" {
  description = "Canned ACL to apply"
  type        = string
  default     = "private"
}

variable "enable_versioning" {
  description = "Enable S3 bucket versioning"
  type        = bool
  default     = true
}

variable "enable_encryption" {
  description = "Enable AES256 encryption"
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Allow destroy even if bucket is not empty (recommended false in prod)"
  type        = bool
  default     = false
}

variable "enable_logging" {
  description = "Enable S3 bucket access logging"
  type        = bool
  default     = true
}

variable "logging_target_bucket" {
  description = "Target bucket for access logs"
  type        = string
  default     = null
}

variable "logging_target_prefix" {
  description = "Prefix for access logs"
  type        = string
  default     = "logs/"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "lifecycle_rules" {
  description = "List of lifecycle rules for the bucket"
  type = list(object({
    id              = string
    status          = string
    prefix          = string
    transition_days = number
    storage_class   = string
    expiration_days = number
  }))
  default = []
  
  validation {
    condition = length(var.lifecycle_rules) == 0 || alltrue([
      for rule in var.lifecycle_rules : 
      rule.transition_days > 0 && rule.expiration_days > 0
    ])
    error_message = "Transition and expiration days must be positive numbers."
  }
}

variable "kms_key_arn" {
  type        = string
  description = "The KMS key ARN to use for bucket encryption"
  default     = null
}
