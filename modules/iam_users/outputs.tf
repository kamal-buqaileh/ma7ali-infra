output "user_name" {
  description = "The name of the IAM user"
  value       = aws_iam_user.this.name
}

output "user_arn" {
  description = "The Amazon Resource Name (ARN) of the IAM user"
  value       = aws_iam_user.this.arn
}

output "user_id" {
  description = "The ID of the IAM user"
  value       = aws_iam_user.this.id
}

output "user_path" {
  description = "The path of the IAM user"
  value       = aws_iam_user.this.path
}

output "group_memberships" {
  description = "List of group names the user is a member of"
  value       = var.group_names
}
