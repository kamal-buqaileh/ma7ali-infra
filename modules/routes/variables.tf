# routes module variables

variable "name" {
  type        = string
  description = "Name prefix for the route tables"
  
  validation {
    condition = can(regex("^[a-z0-9-]+$", var.name))
    error_message = "Route table name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "route_tables" {
  type = list(object({
    name       = string
    routes     = list(object({
      cidr_block     = string
      gateway_id     = optional(string)
      nat_gateway_id = optional(string)
    }))
    subnet_ids = list(string)
    tags       = map(string)
  }))
  description = "List of route table configurations"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all route tables"
  default     = {}
}
