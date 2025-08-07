# Gateways Module
# Handles Internet Gateway, NAT Gateways, and VPC Endpoints

# Internet Gateway
resource "aws_internet_gateway" "this" {
  count = var.create_internet_gateway ? 1 : 0
  
  vpc_id = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name}-igw"
  })
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count = var.create_nat_gateways ? length(var.nat_gateway_subnet_ids) : 0

  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${var.name}-nat-eip-${count.index + 1}"
  })
}

# NAT Gateways
resource "aws_nat_gateway" "this" {
  count = var.create_nat_gateways ? length(var.nat_gateway_subnet_ids) : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = var.nat_gateway_subnet_ids[count.index]

  tags = merge(var.tags, {
    Name = "${var.name}-nat-${count.index + 1}"
  })

  depends_on = [aws_internet_gateway.this]
}

# VPC Endpoints (optional)
resource "aws_vpc_endpoint" "this" {
  for_each = var.vpc_endpoints

  vpc_id              = var.vpc_id
  service_name        = each.value.service_name
  vpc_endpoint_type   = each.value.endpoint_type
  subnet_ids          = each.value.subnet_ids
  security_group_ids  = each.value.security_group_ids
  private_dns_enabled = each.value.private_dns_enabled

  tags = merge(var.tags, each.value.tags, {
    Name = "${var.name}-${each.key}"
  })
} 