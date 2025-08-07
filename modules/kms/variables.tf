variable "description" {
  type        = string
  description = "Description of the KMS key"
  
  validation {
    condition = length(var.description) > 0
    error_message = "Description cannot be empty."
  }
}

variable "alias" {
  type        = string
  description = "Alias for the KMS key (without 'alias/' prefix)"
  
  validation {
    condition = can(regex("^[a-zA-Z0-9/_-]+$", var.alias))
    error_message = "Alias must contain only alphanumeric characters, hyphens, underscores, and forward slashes."
  }
}

variable "enable_key_rotation" {
  type        = bool
  description = "Enable automatic key rotation (recommended for security)"
  default     = true
}

variable "deletion_window_in_days" {
  type        = number
  description = "Number of days to wait before deleting the key (7-30 days)"
  default     = 10
  
  validation {
    condition = var.deletion_window_in_days >= 7 && var.deletion_window_in_days <= 30
    error_message = "Deletion window must be between 7 and 30 days."
  }
}

variable "is_enabled" {
  type        = bool
  description = "Whether the key is enabled for use"
  default     = true
}

variable "key_policy" {
  type        = string
  description = "JSON-formatted IAM policy for the KMS key"
  
  validation {
    condition = can(jsondecode(var.key_policy))
    error_message = "Key policy must be valid JSON."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the KMS key"
  default     = {}
}
