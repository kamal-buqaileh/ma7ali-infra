# route53 module outputs

output "hosted_zone_id" {
  description = "The hosted zone ID"
  value       = local.hosted_zone_id
}

output "hosted_zone_arn" {
  description = "The hosted zone ARN"
  value       = var.create_hosted_zone ? aws_route53_zone.this[0].arn : null
}

output "name_servers" {
  description = "The name servers for the hosted zone"
  value       = local.name_servers
}

output "domain_name" {
  description = "The domain name"
  value       = var.domain_name
}

output "dns_record_fqdns" {
  description = "Map of DNS record FQDNs"
  value       = { for k, v in aws_route53_record.this : k => v.fqdn }
}
