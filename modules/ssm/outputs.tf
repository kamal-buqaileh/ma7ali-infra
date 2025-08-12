output "secret_arns" {
  description = "Map of secret names to their ARNs"
  value = {
    for k, v in aws_secretsmanager_secret.this : k => v.arn
  }
}

output "secret_names" {
  description = "Map of secret keys to their names"
  value = {
    for k, v in aws_secretsmanager_secret.this : k => v.name
  }
}

output "secret_ids" {
  description = "Map of secret keys to their IDs"
  value = {
    for k, v in aws_secretsmanager_secret.this : k => v.id
  }
}

# Individual outputs for easier access
output "secret_arn_by_name" {
  description = "Map of secret names to their ARNs (for easy lookup)"
  value = {
    for k, v in aws_secretsmanager_secret.this : v.name => v.arn
  }
}

output "secret_version_ids" {
  description = "Map of secret keys to their version IDs"
  value = {
    for k, v in aws_secretsmanager_secret_version.this : k => v.version_id
  }
}
