resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "this" {
  bucket        = "${var.bucket_prefix}-${random_id.suffix.hex}"
  force_destroy = var.force_destroy # Only set to true in non-production environments for safety

  tags = var.tags
}

resource "aws_s3_bucket_acl" "this" {
  bucket = aws_s3_bucket.this.id
  acl    = var.acl
}

# Enable versioning only in production environments for data protection and compliance
# 
# WHY CONDITIONAL VERSIONING?
# ===========================
# 1. COST OPTIMIZATION: Versioning doubles storage costs as every version is stored
#    - Staging/dev environments don't need the same level of data protection
#    - Reduces unnecessary costs for development and testing environments
#
# 2. PERFORMANCE: Versioning adds overhead to S3 operations
#    - Faster operations in staging/dev environments for quicker development cycles
#    - Production environments prioritize data protection over speed
#
# 3. ENVIRONMENT SEPARATION: Different environments have different requirements
#    - Production: Data protection, compliance, and recovery capabilities
#    - Staging/Dev: Cost efficiency, speed, and development flexibility
#
# 4. SECURITY STRATEGY: We focus on prevention rather than recovery in non-prod
#    - Staging environments are typically recreated frequently
#    - Development data is not business-critical and can be regenerated
#
# NOTE: This approach may trigger tfsec warnings (aws-s3-enable-versioning)
#       which are suppressed in .tfsecignore for staging environments.
#
resource "aws_s3_bucket_versioning" "this" {
  count  = var.environment == "production" ? 1 : 0
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Configure server-side encryption for data at rest
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count  = var.enable_encryption ? 1 : 0
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.kms_key_arn != null ? "aws:kms" : "AES256"
      kms_master_key_id = var.kms_key_arn
    }
  }
}

# Enable access logging for security, compliance, and audit purposes
resource "aws_s3_bucket_logging" "this" {
  count  = var.enable_logging ? 1 : 0
  bucket = aws_s3_bucket.this.id

  target_bucket = var.logging_target_bucket != null ? var.logging_target_bucket : aws_s3_bucket.this.id
  target_prefix = var.logging_target_prefix
}

# Configure lifecycle rules for cost optimization and data management
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count  = length(var.lifecycle_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    for_each = var.lifecycle_rules
    content {
      id     = rule.value.id
      status = rule.value.status

      filter {
        prefix = rule.value.prefix
      }

      transition {
        days          = rule.value.transition_days
        storage_class = rule.value.storage_class
      }

      expiration {
        days = rule.value.expiration_days
      }
    }
  }
}

# Block all public access to ensure bucket security
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
