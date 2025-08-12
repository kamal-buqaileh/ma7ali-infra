variable "secrets" {
  description = "Map of secrets to create in AWS Secrets Manager"
  type = map(object({
    name        = string
    description = string
    
    # Secret content (choose one)
    secret_json   = optional(map(string))  # For JSON secrets like DB credentials
    secret_string = optional(string)       # For simple string secrets
    secret_binary = optional(string)       # For binary secrets (base64 encoded)
    
    # Optional configurations
    recovery_window_in_days = optional(number)
    policy                  = optional(string)
    version_stages         = optional(list(string))
    tags                   = optional(map(string), {})
    
    # Replication (optional)
    replicas = optional(list(object({
      region     = string
      kms_key_id = optional(string)
    })), [])
    
    # Rotation configuration (optional)
    rotation_config = optional(object({
      lambda_arn               = string
      automatically_after_days = number
    }))
  }))
  default = {}
}

variable "kms_key_arn" {
  description = "ARN of the KMS key to use for encrypting secrets"
  type        = string
}

variable "default_recovery_window_days" {
  description = "Default recovery window in days for secrets deletion"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Common tags to apply to all secrets"
  type        = map(string)
  default     = {}
}
