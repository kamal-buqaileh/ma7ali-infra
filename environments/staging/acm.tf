# ACM SSL Certificate configuration for environment
locals {
  # ACM domain logic
  acm_app_domain   = var.is_production ? var.domain_name : "${var.environment}.${var.domain_name}"
  acm_api_domain   = var.is_production ? "api.${var.domain_name}" : "api.${var.environment}.${var.domain_name}"
  acm_admin_domain = var.is_production ? "admin.${var.domain_name}" : "admin.${var.environment}.${var.domain_name}"

  # Certificate domain: wildcard for production (*.ma7ali.app) or environment subdomain (*.staging.ma7ali.app)
  acm_cert_domain = var.is_production ? "*.${var.domain_name}" : "*.${var.environment}.${var.domain_name}"
}

module "ssl_certificate" {
  source = "../../modules/acm"

  domain_name = local.acm_cert_domain
  subject_alternative_names = [
    local.acm_app_domain,
    local.acm_api_domain,
    local.acm_admin_domain
  ]

  hosted_zone_id = module.route53.hosted_zone_id
  key_algorithm  = "RSA_2048"

  # Enable certificate transparency for security monitoring
  certificate_transparency_logging_preference = "ENABLED"

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "SSL certificate for ${var.environment} applications"
  }
}
