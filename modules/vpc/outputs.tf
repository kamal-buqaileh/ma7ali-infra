output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = aws_vpc.this.arn
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "vpc_endpoint_ids" {
  description = "Map of VPC endpoint IDs"
  value       = { for k, v in aws_vpc_endpoint.this : k => v.id }
}

output "vpc_endpoint_arns" {
  description = "Map of VPC endpoint ARNs"
  value       = { for k, v in aws_vpc_endpoint.this : k => v.arn }
}
