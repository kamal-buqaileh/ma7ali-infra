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

# Route 53 outputs
output "hosted_zone_id" {
  description = "The Route53 hosted zone ID"
  value       = module.route53.hosted_zone_id
}

output "name_servers" {
  description = "The name servers for the domain"
  value       = module.route53.name_servers
}

output "domain_name" {
  description = "The domain name"
  value       = module.route53.domain_name
}

# ACM outputs
output "ssl_certificate_arn" {
  description = "The ARN of the SSL certificate"
  value       = module.ssl_certificate.certificate_arn
}

output "ssl_certificate_status" {
  description = "The status of the SSL certificate"
  value       = module.ssl_certificate.certificate_status
}

# ALB outputs
output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "alb_zone_id" {
  description = "The zone ID of the Application Load Balancer"
  value       = module.alb.alb_zone_id
}

output "alb_arn" {
  description = "The ARN of the Application Load Balancer"
  value       = module.alb.alb_arn
}

output "target_group_arns" {
  description = "Map of target group ARNs"
  value       = module.alb.target_group_arns
}

# RDS outputs
output "rds_instance_id" {
  description = "The RDS instance ID"
  value       = module.rds.db_instance_id
}

output "rds_instance_endpoint" {
  description = "The RDS instance endpoint"
  value       = module.rds.db_instance_endpoint
}

output "rds_instance_address" {
  description = "The RDS instance hostname"
  value       = module.rds.db_instance_address
}

output "rds_instance_port" {
  description = "The RDS instance port"
  value       = module.rds.db_instance_port
}

output "rds_database_name" {
  description = "The database name"
  value       = module.rds.db_instance_name
}

output "rds_password_secret_arn" {
  description = "The ARN of the Secrets Manager secret containing the database password"
  value       = module.rds.db_instance_password_secret_arn
}

output "rds_password_secret_name" {
  description = "The name of the Secrets Manager secret containing the database password"
  value       = module.rds.db_instance_password_secret_name
}

output "rds_connection_string" {
  description = "PostgreSQL connection string (without password)"
  value       = module.rds.connection_string
  sensitive   = true
}

output "rds_jdbc_connection_string" {
  description = "JDBC connection string (without password)"
  value       = module.rds.jdbc_connection_string
}
