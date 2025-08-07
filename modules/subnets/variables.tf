# subnets module variables

variable "name" {
  type        = string
  description = "Name prefix for the subnets"
  
  validation {
    condition = can(regex("^[a-z0-9-]+$", var.name))
    error_message = "Subnet name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "subnets" {
  type = list(object({
    cidr_block              = string
    availability_zone       = string
    tier                    = string
    map_public_ip_on_launch = bool
    tags                    = map(string)
  }))
  description = "List of subnet configurations"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all subnets"
  default     = {}
}
