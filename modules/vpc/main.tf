# Create the main VPC for the infrastructure
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name = "${var.name}-vpc"
  })
}

# VPC Endpoints
resource "aws_vpc_endpoint" "this" {
  for_each = var.vpc_endpoints

  vpc_id              = aws_vpc.this.id
  service_name        = each.value.service_name
  vpc_endpoint_type   = each.value.endpoint_type
  # Only Interface endpoints use subnet_ids
  subnet_ids          = each.value.endpoint_type == "Interface" ? each.value.subnet_ids : null
  security_group_ids  = each.value.security_group_ids
  private_dns_enabled = each.value.private_dns_enabled

  # Only Gateway endpoints (e.g., S3) use route_table_ids
  route_table_ids     = each.value.endpoint_type == "Gateway" ? coalesce(each.value.route_table_ids, []) : null

  # Attach policy if provided
  policy              = each.value.policy

  tags = merge(var.tags, each.value.tags, {
    Name = "${var.name}-${each.key}-endpoint"
  })
}
