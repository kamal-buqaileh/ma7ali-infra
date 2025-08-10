# route53 module

# Create hosted zone if requested
resource "aws_route53_zone" "this" {
  count = var.create_hosted_zone ? 1 : 0
  name  = var.domain_name

  tags = merge(var.tags, {
    Name = "${var.domain_name}-hosted-zone"
  })
}

# Data source for existing hosted zone
data "aws_route53_zone" "existing" {
  count   = var.create_hosted_zone ? 0 : 1
  zone_id = var.hosted_zone_id
}

# Local to determine which hosted zone to use
locals {
  hosted_zone_id = var.create_hosted_zone ? aws_route53_zone.this[0].zone_id : data.aws_route53_zone.existing[0].zone_id
  name_servers   = var.create_hosted_zone ? aws_route53_zone.this[0].name_servers : data.aws_route53_zone.existing[0].name_servers
}

# Create DNS records
resource "aws_route53_record" "this" {
  for_each = var.dns_records

  zone_id = local.hosted_zone_id
  name    = each.key
  type    = each.value.type

  # For alias records
  dynamic "alias" {
    for_each = each.value.alias != null ? [each.value.alias] : []
    content {
      name                   = alias.value.name
      zone_id                = alias.value.zone_id
      evaluate_target_health = alias.value.evaluate_target_health
    }
  }

  # For regular records
  ttl     = each.value.alias == null ? each.value.ttl : null
  records = each.value.alias == null ? each.value.records : null
}
