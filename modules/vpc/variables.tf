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

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the VPC"
  default     = {}
}
