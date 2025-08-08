# S3 outputs
output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = module.s3.bucket_id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = module.s3.bucket_arn
}

output "s3_kms_key_arn" {
  description = "The ARN of the S3 KMS key"
  value       = aws_kms_key.s3_key.arn
}

# KMS outputs
output "main_kms_key_arn" {
  description = "The ARN of the main KMS key"
  value       = module.main_kms_key.arn
}

# VPC outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = module.gateways.internet_gateway_id
}

# Subnet outputs
output "subnet_ids" {
  description = "List of all subnet IDs"
  value       = module.subnets.subnet_ids
}

output "subnets_by_tier" {
  description = "Map of subnet IDs grouped by tier"
  value       = module.subnets.subnets_by_tier
}

# Route outputs
output "route_table_ids" {
  description = "List of route table IDs"
  value       = module.routes.route_table_ids
}

# CloudWatch outputs
output "flow_log_id" {
  description = "The ID of the VPC flow log"
  value       = module.cloudwatch.flow_log_id
}

# IAM outputs
output "flow_log_role_arn" {
  description = "The ARN of the VPC flow log IAM role"
  value       = var.enable_vpc_flow_logs ? aws_iam_role.flow_log[0].arn : null
}

output "github_actions_role_arn" {
  description = "The ARN of the GitHub Actions role for CI/CD"
  value       = aws_iam_role.github_actions_deployer.arn
}

output "github_oidc_provider_arn" {
  description = "The ARN of the GitHub OIDC identity provider"
  value       = aws_iam_openid_connect_provider.github.arn
}
