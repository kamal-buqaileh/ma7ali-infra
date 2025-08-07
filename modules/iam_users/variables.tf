variable "user_name" {
  type        = string
  description = "The name of the IAM user"
}

variable "group_names" {
  type        = list(string)
  description = "List of IAM group names to assign to the user"
}
