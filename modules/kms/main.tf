# Create a KMS key for encryption and decryption operations
# This key can be used for encrypting data at rest and in transit
resource "aws_kms_key" "this" {
  description             = var.description
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.enable_key_rotation
  is_enabled              = var.is_enabled

  policy = var.key_policy

  tags = var.tags
}

# Create an alias for the KMS key for easier reference and management
# Aliases provide a friendly name for the key (e.g., alias/my-app-key)
resource "aws_kms_alias" "this" {
  name          = "alias/${var.alias}"
  target_key_id = aws_kms_key.this.key_id
}
