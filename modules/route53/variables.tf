# route53 module variables

variable "domain_name" {
  type        = string
  description = "The domain name for the hosted zone"
  validation {
    condition     = can(regex("^[a-z0-9.-]+\\.[a-z]{2,}$", var.domain_name))
    error_message = "Domain name must be a valid domain format (e.g., example.com)."
  }
}

variable "create_hosted_zone" {
  type        = bool
  description = "Whether to create a new hosted zone or use existing one"
  default     = true
}

variable "hosted_zone_id" {
  type        = string
  description = "Existing hosted zone ID (required if create_hosted_zone is false)"
  default     = null
}

variable "dns_records" {
  type = map(object({
    type    = string
    ttl     = optional(number, 300)
    records = optional(list(string), [])
    alias = optional(object({
      name                   = string
      zone_id                = string
      evaluate_target_health = optional(bool, false)
    }), null)
  }))
  description = "Map of DNS records to create"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to Route53 resources"
  default     = {}
}
