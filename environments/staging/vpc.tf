module "vpc" {
  source = "../../modules/vpc"

  name     = "${var.project_name}-${var.environment}"
  vpc_cidr = "10.0.0.0/16"

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc"
    Environment = var.environment
    Purpose     = "Main VPC"
  }
}
