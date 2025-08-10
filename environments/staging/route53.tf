# Route 53 configuration for environment
locals {
  # Route53 domain logic
  route53_app_domain   = var.is_production ? var.domain_name : "${var.environment}.${var.domain_name}"
  route53_api_domain   = var.is_production ? "api.${var.domain_name}" : "api.${var.environment}.${var.domain_name}"
  route53_admin_domain = var.is_production ? "admin.${var.domain_name}" : "admin.${var.environment}.${var.domain_name}"
}

module "route53" {
  source = "../../modules/route53"

  domain_name = var.domain_name

  # DNS records for environment
  dns_records = {
    # Environment main domain - ALIAS to ALB
    "${local.route53_app_domain}" = {
      type = "A"
      alias = {
        name                   = module.alb.alb_dns_name
        zone_id                = module.alb.alb_zone_id
        evaluate_target_health = true
      }
    }

    # Environment API subdomain - ALIAS to ALB
    "${local.route53_api_domain}" = {
      type = "A"
      alias = {
        name                   = module.alb.alb_dns_name
        zone_id                = module.alb.alb_zone_id
        evaluate_target_health = true
      }
    }

    # Environment Admin subdomain - ALIAS to ALB
    "${local.route53_admin_domain}" = {
      type = "A"
      alias = {
        name                   = module.alb.alb_dns_name
        zone_id                = module.alb.alb_zone_id
        evaluate_target_health = true
      }
    }

    # DMARC policy for email security
    "_dmarc.${var.domain_name}" = {
      type    = "TXT"
      ttl     = 3600
      records = ["v=DMARC1; p=reject; rua=mailto:dmarc@${var.domain_name}"]
    }

    # SPF record for email security (prevents email spoofing)
    "spf.${var.domain_name}" = {
      type    = "TXT"
      ttl     = 3600
      records = ["v=spf1 include:_spf.google.com ~all"]
    }

    # DKIM record placeholder (you'll get this from your email provider)
    # "default._domainkey.${var.domain_name}" = {
    #   type    = "TXT"
    #   ttl     = 3600
    #   records = ["v=DKIM1; k=rsa; p=YOUR_DKIM_PUBLIC_KEY_HERE"]
    # }

    # CAA record (Certificate Authority Authorization) - restricts who can issue SSL certificates
    "caa.${var.domain_name}" = {
      type = "CAA"
      ttl  = 3600
      records = [
        "0 issue \"amazon.com\"",
        "0 issue \"letsencrypt.org\"",
        "0 iodef \"mailto:security@${var.domain_name}\""
      ]
    }
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "DNS management"
  }
}
