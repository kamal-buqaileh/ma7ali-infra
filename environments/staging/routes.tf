# For now, let's create a simple public route table only
# Private routes will be added when NAT gateways are created
module "routes" {
  source = "../../modules/routes"

  name   = "${var.project_name}-${var.environment}"
  vpc_id = module.vpc.vpc_id

  route_tables = [
    {
      name = "public"
      routes = [
        {
          cidr_block = "0.0.0.0/0"
          gateway_id = module.gateways.internet_gateway_id
        }
      ]
      subnet_ids = module.subnets.subnets_by_tier["Public"]
      tags = {
        Purpose = "Public route table"
      }
    }
  ]

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}
