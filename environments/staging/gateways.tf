# Gateways configuration for staging environment
module "gateways" {
  source = "../../modules/gateways"

  name   = "${var.project_name}-${var.environment}"
  vpc_id = module.vpc.vpc_id

  # Create Internet Gateway for public subnets
  create_internet_gateway = true


  tags = {
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "VPC gateways"
  }
} 