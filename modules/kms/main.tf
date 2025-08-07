resource "aws_kms_key" "this" {
  description             = var.description
  deletion_window_in_days = 10
  enable_key_rotation     = var.enable_key_rotation

  policy = var.key_policy
}

resource "aws_kms_alias" "this" {
  name          = "alias/${var.alias}"
  target_key_id = aws_kms_key.this.key_id
}
