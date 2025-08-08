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

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all gateways"
  default     = {}
} 