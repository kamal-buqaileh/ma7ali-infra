variable "name" {
  type        = string
  description = "Name of the IAM policy"
  
  validation {
    condition = can(regex("^[a-zA-Z0-9+=,.@_-]+$", var.name))
    error_message = "Policy name must contain only alphanumeric characters, hyphens, underscores, periods, @ symbols, plus signs, equals signs, and commas."
  }
}

variable "description" {
  type        = string
  description = "Description of the IAM policy"
  
  validation {
    condition = length(var.description) > 0
    error_message = "Description cannot be empty."
  }
}

variable "path" {
  type        = string
  description = "Path to the policy (default: /)"
  default     = "/"
  
  validation {
    condition = can(regex("^/.*", var.path))
    error_message = "Path must start with a forward slash (/)."
  }
}

variable "policy_document" {
  type        = any
  description = "IAM policy document as JSON object"
  
  validation {
    condition = can(jsonencode(var.policy_document))
    error_message = "Policy document must be valid JSON."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the IAM policy"
  default     = {}
}
