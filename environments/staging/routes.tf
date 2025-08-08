# For now, let's create a simple public route table only
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
    },
    {
      name       = "private"
      routes     = []
      subnet_ids = module.subnets.subnets_by_tier["Private"]
      tags = {
        Purpose = "Private route table"
      }
    }
  ]

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}
