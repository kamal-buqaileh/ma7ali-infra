module "subnets" {
  source = "../../modules/subnets"

  name   = "${var.project_name}-${var.environment}"
  vpc_id = module.vpc.vpc_id

  subnets = [
    {
      cidr_block              = "10.0.1.0/24"
      availability_zone       = "us-west-2a"
      tier                    = "Public"
      map_public_ip_on_launch = true
      tags = {
        Purpose = "Public subnets for ALB"
      }
    },
    {
      cidr_block              = "10.0.2.0/24"
      availability_zone       = "us-west-2b"
      tier                    = "Public"
      map_public_ip_on_launch = true
      tags = {
        Purpose = "Public subnets for ALB"
      }
    },
    {
      cidr_block              = "10.0.10.0/24"
      availability_zone       = "us-west-2a"
      tier                    = "Private"
      map_public_ip_on_launch = false
      tags = {
        Purpose = "Private subnets for EKS"
      }
    },
    {
      cidr_block              = "10.0.11.0/24"
      availability_zone       = "us-west-2b"
      tier                    = "Private"
      map_public_ip_on_launch = false
      tags = {
        Purpose = "Private subnets for EKS"
      }
    },
    {
      cidr_block              = "10.0.20.0/24"
      availability_zone       = "us-west-2a"
      tier                    = "Database"
      map_public_ip_on_launch = false
      tags = {
        Purpose = "Database subnets for RDS"
      }
    },
    {
      cidr_block              = "10.0.21.0/24"
      availability_zone       = "us-west-2b"
      tier                    = "Database"
      map_public_ip_on_launch = false
      tags = {
        Purpose = "Database subnets for RDS"
      }
    }
  ]

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}
