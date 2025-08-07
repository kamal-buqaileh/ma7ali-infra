output "bucket_name" {
  description = "The name of the bucket"
  value       = aws_s3_bucket.this.bucket
}

output "bucket_arn" {
  description = "The ARN of the bucket"
  value       = aws_s3_bucket.this.arn
}

output "bucket_id" {
  description = "The name of the bucket"
  value       = aws_s3_bucket.this.id
}

output "bucket_region" {
  description = "The AWS region this bucket resides in"
  value       = aws_s3_bucket.this.region
}

output "versioning_enabled" {
  description = "Whether versioning is enabled (only in production environments for cost optimization)"
  value       = var.environment == "production"
}

output "versioning_status" {
  description = "The versioning status of the bucket (Enabled in production, Disabled in staging/dev for cost optimization)"
  value       = var.environment == "production" ? "Enabled" : "Disabled"
}