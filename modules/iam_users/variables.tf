variable "user_name" {
  type        = string
  description = "The name of the IAM user"
  
  validation {
    condition = can(regex("^[a-zA-Z0-9+=,.@_-]+$", var.user_name))
    error_message = "User name must contain only alphanumeric characters, hyphens, underscores, periods, @ symbols, plus signs, equals signs, and commas."
  }
}

variable "path" {
  type        = string
  description = "Path to the user (default: /)"
  default     = "/"
  
  validation {
    condition = can(regex("^/.*", var.path))
    error_message = "Path must start with a forward slash (/)."
  }
}

variable "group_names" {
  type        = list(string)
  description = "List of IAM group names to assign to the user"
  
  validation {
    condition = alltrue([
      for group_name in var.group_names : 
      can(regex("^[a-zA-Z0-9+=,.@_-]+$", group_name))
    ])
    error_message = "All group names must contain only alphanumeric characters, hyphens, underscores, periods, @ symbols, plus signs, equals signs, and commas."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the IAM user"
  default     = {}
}
