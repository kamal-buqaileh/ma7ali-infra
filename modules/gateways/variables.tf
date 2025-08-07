# Gateways module variables

variable "name" {
  type        = string
  description = "Name prefix for the gateways"
  
  validation {
    condition = can(regex("^[a-z0-9-]+$", var.name))
    error_message = "Gateway name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "create_internet_gateway" {
  type        = bool
  description = "Whether to create an Internet Gateway"
  default     = true
}

variable "create_nat_gateways" {
  type        = bool
  description = "Whether to create NAT Gateways"
  default     = false
}

variable "nat_gateway_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs where NAT Gateways should be created"
  default     = []
}

variable "vpc_endpoints" {
  type = map(object({
    service_name        = string
    endpoint_type       = string
    subnet_ids          = list(string)
    security_group_ids  = list(string)
    private_dns_enabled = bool
    tags               = map(string)
  }))
  description = "Map of VPC endpoints to create"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all gateways"
  default     = {}
} 