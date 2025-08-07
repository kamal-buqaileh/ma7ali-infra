# Create subnets based on the provided configuration
resource "aws_subnet" "this" {
  count             = length(var.subnets)
  vpc_id            = var.vpc_id
  cidr_block        = var.subnets[count.index].cidr_block
  availability_zone = var.subnets[count.index].availability_zone

  map_public_ip_on_launch = var.subnets[count.index].map_public_ip_on_launch

  tags = merge(var.tags, var.subnets[count.index].tags, {
    Name = "${var.name}-${var.subnets[count.index].tier}-${var.subnets[count.index].availability_zone}"
    Tier = var.subnets[count.index].tier
  })
}
