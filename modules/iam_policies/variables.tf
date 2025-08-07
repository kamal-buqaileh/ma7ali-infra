variable "name" {
  type        = string
  description = "Name of the IAM policy"
}

variable "description" {
  type        = string
  description = "Description of the IAM policy"
}

variable "policy_document" {
  type        = any
  description = "IAM policy document as JSON object"
}
