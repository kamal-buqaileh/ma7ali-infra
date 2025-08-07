# subnets module outputs

output "subnet_ids" {
  description = "List of subnet IDs"
  value       = aws_subnet.this[*].id
}

output "subnet_arns" {
  description = "List of subnet ARNs"
  value       = aws_subnet.this[*].arn
}

output "subnet_cidr_blocks" {
  description = "List of subnet CIDR blocks"
  value       = aws_subnet.this[*].cidr_block
}

output "subnets_by_tier" {
  description = "Map of subnet IDs grouped by tier"
  value = {
    for tier in distinct([for subnet in var.subnets : subnet.tier]) :
    tier => [
      for i, subnet in aws_subnet.this :
      subnet.id if var.subnets[i].tier == tier
    ]
  }
}
