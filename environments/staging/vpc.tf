module "vpc" {
  source = "../../modules/vpc"

  name     = "${var.project_name}-${var.environment}"
  vpc_cidr = "10.0.0.0/16"

  # VPC Endpoints for AWS services (cost-effective alternative to NAT Gateway)
  vpc_endpoints = {
    # S3 Gateway Endpoint - FREE!
    s3 = {
      service_name       = "com.amazonaws.${var.aws_region}.s3"
      endpoint_type      = "Gateway"
      security_group_ids = []
      subnet_ids         = []
      route_table_ids = [
        #module.routes.route_tables_by_name["public"],
        module.routes.route_tables_by_name["private"]
      ]
      private_dns_enabled = false
      tags = {
        Purpose = "S3 access for ECR image layers"
        Service = "S3"
      }
    }

    # ECR API Interface Endpoint - ~$7/month
    ecr_api = {
      service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
      endpoint_type       = "Interface"
      subnet_ids          = module.subnets.subnets_by_tier["Private"]
      security_group_ids  = []
      private_dns_enabled = true
      tags = {
        Purpose = "ECR API access for repository management"
        Service = "ECR"
      }
    }

    # ECR Docker Registry Interface Endpoint - ~$7/month
    ecr_dkr = {
      service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
      endpoint_type       = "Interface"
      subnet_ids          = module.subnets.subnets_by_tier["Private"]
      security_group_ids  = []
      private_dns_enabled = true
      tags = {
        Purpose = "ECR Docker registry for image push/pull"
        Service = "ECR"
      }
    }

    # CloudWatch Logs Interface Endpoint - ~$7/month (optional)
    # logs = {
    #   service_name        = "com.amazonaws.${var.aws_region}.logs"
    #   endpoint_type       = "Interface"
    #   subnet_ids          = module.subnets.subnets_by_tier["Private"]
    #   security_group_ids  = []
    #   private_dns_enabled = true
    #   tags = {
    #     Purpose = "CloudWatch Logs access for application logging"
    #     Service = "CloudWatch"
    #   }
    # }
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc"
    Environment = var.environment
    Purpose     = "Main VPC with VPC endpoints"
  }
}
