# AWS Secrets Manager module
# Centralized management of secrets for applications and infrastructure

# Create Secrets Manager secrets
resource "aws_secretsmanager_secret" "this" {
  for_each = var.secrets

  name                    = each.value.name
  description             = each.value.description
  recovery_window_in_days = lookup(each.value, "recovery_window_in_days", var.default_recovery_window_days)
  kms_key_id             = var.kms_key_arn
  policy                 = lookup(each.value, "policy", null)

  # Automatic rotation configuration (if specified)
  dynamic "replica" {
    for_each = lookup(each.value, "replicas", [])
    content {
      region     = replica.value.region
      kms_key_id = lookup(replica.value, "kms_key_id", null)
    }
  }

  tags = merge(var.tags, lookup(each.value, "tags", {}), {
    Name = each.value.name
  })
}

# Store secret values
resource "aws_secretsmanager_secret_version" "this" {
  for_each = var.secrets

  secret_id = aws_secretsmanager_secret.this[each.key].id
  
  # Support both JSON and string secret values
  secret_string = lookup(each.value, "secret_json", null) != null ? jsonencode(each.value.secret_json) : lookup(each.value, "secret_string", null)
  
  # Support binary secrets
  secret_binary = lookup(each.value, "secret_binary", null)

  # Version stages (if specified)
  version_stages = lookup(each.value, "version_stages", null)

  lifecycle {
    ignore_changes = [
      # Ignore changes to secret values if they're managed externally
      secret_string,
      secret_binary
    ]
  }
}

# Optional: Automatic rotation (for supported services)
resource "aws_secretsmanager_secret_rotation" "this" {
  for_each = {
    for k, v in var.secrets : k => v
    if lookup(v, "rotation_config", null) != null
  }

  secret_id           = aws_secretsmanager_secret.this[each.key].id
  rotation_lambda_arn = each.value.rotation_config.lambda_arn

  rotation_rules {
    automatically_after_days = each.value.rotation_config.automatically_after_days
  }
}
