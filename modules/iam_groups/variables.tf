variable "group_name" {
  type        = string
  description = "Name of the IAM group"
}

variable "policy_arn_map" {
  type        = map(string)
  description = "Map of policy ARNs to attach"
}

variable "enforce_mfa" {
  type        = bool
  description = "Whether to enforce MFA for this group"
  default     = false
}
