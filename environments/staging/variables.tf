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