# Gateways module outputs

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = var.create_internet_gateway ? aws_internet_gateway.this[0].id : null
}

output "internet_gateway_arn" {
  description = "The ARN of the Internet Gateway"
  value       = var.create_internet_gateway ? aws_internet_gateway.this[0].arn : null
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = var.create_nat_gateways ? aws_nat_gateway.this[*].id : []
}

output "nat_gateway_arns" {
  description = "List of NAT Gateway ARNs"
  value       = var.create_nat_gateways ? aws_nat_gateway.this[*].arn : []
}

output "nat_gateway_public_ips" {
  description = "List of NAT Gateway public IPs"
  value       = var.create_nat_gateways ? aws_eip.nat[*].public_ip : []
}

output "vpc_endpoint_ids" {
  description = "Map of VPC endpoint IDs"
  value       = { for k, v in aws_vpc_endpoint.this : k => v.id }
}

output "vpc_endpoint_arns" {
  description = "Map of VPC endpoint ARNs"
  value       = { for k, v in aws_vpc_endpoint.this : k => v.arn }
} 