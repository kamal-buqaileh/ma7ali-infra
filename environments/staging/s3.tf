module "s3" {
  source            = "../../modules/s3"
  bucket_prefix     = "${var.project_name}-${var.environment}"
  environment       = var.environment
  acl               = "private"
  enable_versioning = true
  enable_encryption = true
  force_destroy     = true
  kms_key_arn       = aws_kms_key.s3_key.arn
  lifecycle_rules   = var.s3_lifecycle_rules

  tags = {
    Name        = "${var.project_name}-${var.environment}"
    Environment = var.environment
  }
}