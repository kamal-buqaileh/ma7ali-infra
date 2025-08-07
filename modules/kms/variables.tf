variable "description" {
  type        = string
  description = "Description of the KMS key"
}

variable "alias" {
  type        = string
  description = "Alias for the KMS key (without 'alias/' prefix)"
}

variable "enable_key_rotation" {
  type        = bool
  description = "Enable automatic key rotation"
  default     = true
}

variable "key_policy" {
  type        = string
  description = "JSON-formatted IAM policy for the KMS key"
}
