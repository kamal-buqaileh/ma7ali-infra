output "arn" {
  description = "The Amazon Resource Name (ARN) of the created IAM policy"
  value       = aws_iam_policy.this.arn
}

output "id" {
  description = "The ID of the IAM policy"
  value       = aws_iam_policy.this.id
}

output "name" {
  description = "The name of the IAM policy"
  value       = aws_iam_policy.this.name
}

output "path" {
  description = "The path of the IAM policy"
  value       = aws_iam_policy.this.path
}

output "policy_id" {
  description = "The ID of the policy"
  value       = aws_iam_policy.this.policy_id
}
