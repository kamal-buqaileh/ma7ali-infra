module "main_kms_key" {
  source                  = "../../modules/kms"
  description             = "Main KMS key for staging environment"
  alias                   = "main-key-staging"
  enable_key_rotation     = true
  deletion_window_in_days = 10
  is_enabled              = true

  key_policy = jsonencode({
    Version = "2012-10-17",
    Id      = "key-default-1",
    Statement = [
      {
        Sid    = "Allow root account full access"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-main-key"
    Environment = var.environment
    Purpose     = "Main encryption key"
  }
}

resource "aws_kms_key" "s3_key" {
  description             = "KMS key for S3 bucket encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  is_enabled              = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-s3-key"
    Environment = var.environment
    Purpose     = "S3 bucket encryption"
  }
}

