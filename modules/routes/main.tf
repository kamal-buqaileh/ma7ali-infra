# Create route tables based on the provided configuration
resource "aws_route_table" "this" {
  count  = length(var.route_tables)
  vpc_id = var.vpc_id

  tags = merge(var.tags, var.route_tables[count.index].tags, {
    Name = "${var.name}-${var.route_tables[count.index].name}"
  })
}

# Create routes for each route table
resource "aws_route" "this" {
  count = length(var.route_tables)

  route_table_id = aws_route_table.this[count.index].id

  # Route configuration
  destination_cidr_block = length(var.route_tables[count.index].routes) > 0 ? var.route_tables[count.index].routes[0].cidr_block : null

  # Gateway or NAT Gateway (only set if provided)
  gateway_id     = length(var.route_tables[count.index].routes) > 0 ? try(var.route_tables[count.index].routes[0].gateway_id, null) : null
  nat_gateway_id = length(var.route_tables[count.index].routes) > 0 ? try(var.route_tables[count.index].routes[0].nat_gateway_id, null) : null
}

# Associate route tables with subnets using for_each
resource "aws_route_table_association" "this" {
  for_each = merge([
    for rt_index, route_table in var.route_tables : {
      for subnet_index, subnet_id in route_table.subnet_ids : "${rt_index}-${subnet_index}" => {
        route_table_index = rt_index
        subnet_id         = subnet_id
      }
    }
  ]...)

  subnet_id      = each.value.subnet_id
  route_table_id = aws_route_table.this[each.value.route_table_index].id
}
