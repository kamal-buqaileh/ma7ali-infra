output "key_id" {
  description = "The globally unique identifier for the key"
  value       = aws_kms_key.this.key_id
}

output "arn" {
  description = "The Amazon Resource Name (ARN) of the key"
  value       = aws_kms_key.this.arn
}

output "alias_name" {
  description = "The alias name of the key"
  value       = aws_kms_alias.this.name
}

output "alias_arn" {
  description = "The Amazon Resource Name (ARN) of the key alias"
  value       = aws_kms_alias.this.arn
}

output "key_rotation_enabled" {
  description = "Whether key rotation is enabled"
  value       = aws_kms_key.this.enable_key_rotation
}