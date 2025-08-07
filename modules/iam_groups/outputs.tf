output "group_name" {
  description = "The name of the IAM group"
  value       = aws_iam_group.this.name
}

output "group_arn" {
  description = "The Amazon Resource Name (ARN) of the IAM group"
  value       = aws_iam_group.this.arn
}

output "group_id" {
  description = "The ID of the IAM group"
  value       = aws_iam_group.this.id
}

output "group_path" {
  description = "The path of the IAM group"
  value       = aws_iam_group.this.path
}

output "mfa_enforced" {
  description = "Whether MFA is enforced for this group"
  value       = var.enforce_mfa
}
