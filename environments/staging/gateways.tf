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

# NAT Gateway for private subnet internet access
# Create Elastic IP for NAT Gateway
resource "aws_eip" "nat_gateway" {
  domain = "vpc"

  tags = {
    Name        = "${var.project_name}-${var.environment}-nat-gateway-eip"
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "NAT Gateway Elastic IP"
  }

  depends_on = [module.gateways]
}

# Create NAT Gateway in the first public subnet
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = module.subnets.subnets_by_tier["Public"][0]

  tags = {
    Name        = "${var.project_name}-${var.environment}-nat-gateway"
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "NAT Gateway for private subnet internet access"
  }

  depends_on = [module.gateways]
} 