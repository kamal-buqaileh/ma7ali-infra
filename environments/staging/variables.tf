variable "acl" {
  type    = string
  default = "private"
}

variable "environment" {
  type    = string
  default = "staging"
}

variable "aws_region" {
  default = "eu-central-1"
}

variable "project_name" {
  type    = string
  default = "ma7ali"
}

variable "s3_lifecycle_rules" {
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
}

variable "enable_vpc_flow_logs" {
  description = "Whether to enable VPC flow logs"
  type        = bool
  default     = true
}

variable "github_repositories" {
  type        = list(string)
  description = "List of GitHub repositories in format 'owner/repo' for OIDC authentication"
  validation {
    condition = alltrue([
      for repo in var.github_repositories : can(regex("^[a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+$", repo))
    ])
    error_message = "All GitHub repositories must be in format 'owner/repo'."
  }
}

variable "domain_name" {
  type        = string
  description = "The domain name for the application"
  default     = "ma7ali.app"
  validation {
    condition     = can(regex("^[a-z0-9.-]+\\.[a-z]{2,}$", var.domain_name))
    error_message = "Domain name must be a valid domain format (e.g., example.com)."
  }
}

variable "is_production" {
  type        = bool
  description = "Whether this is the production environment (uses root domain instead of subdomain)"
  default     = false
}

