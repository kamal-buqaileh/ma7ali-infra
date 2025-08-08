variable "name" {
  type        = string
  description = "Name of the VPC"
  
  validation {
    condition = can(regex("^[a-z0-9-]+$", var.name))
    error_message = "VPC name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
  
  validation {
    condition = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid CIDR block."
  }
}

variable "vpc_endpoints" {
  type = map(object({
    service_name        = string
    endpoint_type       = string
    subnet_ids          = list(string)
    security_group_ids  = list(string)
    private_dns_enabled = bool
    # For Gateway endpoints (e.g., S3), allow specifying route tables to associate
    route_table_ids     = optional(list(string), null)
    tags                = map(string)
  }))
  description = "Map of VPC endpoints to create"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the VPC"
  default     = {}
}
