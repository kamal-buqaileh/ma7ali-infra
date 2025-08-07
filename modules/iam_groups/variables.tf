variable "group_name" {
  type        = string
  description = "Name of the IAM group"
  
  validation {
    condition = can(regex("^[a-zA-Z0-9+=,.@_-]+$", var.group_name))
    error_message = "Group name must contain only alphanumeric characters, hyphens, underscores, periods, @ symbols, plus signs, equals signs, and commas."
  }
}

variable "path" {
  type        = string
  description = "Path to the group (default: /)"
  default     = "/"
  
  validation {
    condition = can(regex("^/.*", var.path))
    error_message = "Path must start with a forward slash (/)."
  }
}

variable "policy_arn_map" {
  type        = map(string)
  description = "Map of policy ARNs to attach to the group"
  
  validation {
    condition = alltrue([
      for arn in values(var.policy_arn_map) : 
      can(regex("^arn:aws:iam::[0-9]{12}:policy/.*", arn))
    ])
    error_message = "All policy ARNs must be valid IAM policy ARNs."
  }
}

variable "enforce_mfa" {
  type        = bool
  description = "Whether to enforce MFA for this group (recommended for security)"
  default     = false
}
