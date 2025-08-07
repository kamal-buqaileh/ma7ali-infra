# cloudwatch module outputs

output "log_group_names" {
  description = "Map of log group names"
  value = {
    for k, v in aws_cloudwatch_log_group.this : k => v.name
  }
}

output "log_group_arns" {
  description = "Map of log group ARNs"
  value = {
    for k, v in aws_cloudwatch_log_group.this : k => v.arn
  }
}

output "flow_log_id" {
  description = "The ID of the VPC flow log"
  value       = var.enable_vpc_flow_logs ? aws_flow_log.this[0].id : null
}

output "flow_log_arn" {
  description = "The ARN of the VPC flow log"
  value       = var.enable_vpc_flow_logs ? aws_flow_log.this[0].arn : null
}
