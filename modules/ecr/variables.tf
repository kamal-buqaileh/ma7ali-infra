# ecr module variables

variable "name_prefix" {
  type        = string
  description = "Prefix to use for ECR repository names"
  validation {
    condition     = length(var.name_prefix) > 0
    error_message = "name_prefix cannot be empty."
  }
}

variable "repositories" {
  description = "Map of ECR repositories to create and their settings"
  type = map(object({
    image_tag_mutability = optional(string, "IMMUTABLE")
    scan_on_push         = optional(bool, true)
    encryption_type      = optional(string, "KMS")          # KMS or AES256
    kms_key_arn          = optional(string)                  # required if encryption_type == KMS and using CMK
    force_delete         = optional(bool, false)             # allow delete of repos with images (non-prod only)
    lifecycle_policy     = optional(string)                  # JSON text for lifecycle policy
    tags                 = optional(map(string), {})
  }))
  default = {}
}

variable "tags" {
  type        = map(string)
  description = "Common tags to apply to all repositories"
  default     = {}
}

# ecr module variables
