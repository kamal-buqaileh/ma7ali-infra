# acm module outputs

output "certificate_arn" {
  description = "The ARN of the certificate"
  value       = aws_acm_certificate_validation.this.certificate_arn
}

output "certificate_domain_name" {
  description = "The domain name of the certificate"
  value       = aws_acm_certificate.this.domain_name
}

output "certificate_status" {
  description = "The status of the certificate"
  value       = aws_acm_certificate.this.status
}

output "certificate_subject_alternative_names" {
  description = "The subject alternative names of the certificate"
  value       = aws_acm_certificate.this.subject_alternative_names
}

output "validation_record_fqdns" {
  description = "The FQDNs of the validation records"
  value       = [for record in aws_route53_record.validation : record.fqdn]
}
