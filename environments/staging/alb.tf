# Application Load Balancer configuration for environment
locals {
  # ALB domain logic
  alb_app_domain   = var.is_production ? var.domain_name : "${var.environment}.${var.domain_name}"
  alb_api_domain   = var.is_production ? "api.${var.domain_name}" : "api.${var.environment}.${var.domain_name}"
  alb_admin_domain = var.is_production ? "admin.${var.domain_name}" : "admin.${var.environment}.${var.domain_name}"
}

module "alb" {
  source = "../../modules/alb"

  name           = "${var.project_name}-${var.environment}-alb"
  vpc_id         = module.vpc.vpc_id
  vpc_cidr_block = module.vpc.vpc_cidr_block
  subnet_ids     = module.subnets.subnets_by_tier["Public"]

  # Use the SSL certificate from ACM
  certificate_arn = module.ssl_certificate.certificate_arn

  # Modern SSL policy for better security
  ssl_policy = "ELBSecurityPolicy-FS-1-2-Res-2020-10"

  # Health check for default target group
  health_check_path = "/health"

  # Target groups for different services
  target_groups = {
    # Main environment application
    app = {
      port              = 3000
      protocol          = "HTTP"
      priority          = 100
      host_headers      = [local.alb_app_domain]
      health_check_path = "/health"
    }

    # Environment API
    api = {
      port              = 8000
      protocol          = "HTTP"
      priority          = 200
      host_headers      = [local.alb_api_domain]
      health_check_path = "/api/health"
    }

    # Environment Admin
    admin = {
      port              = 3001
      protocol          = "HTTP"
      priority          = 300
      host_headers      = [local.alb_admin_domain]
      health_check_path = "/admin/health"
    }
  }

  # Enable deletion protection for staging (can be disabled for dev)
  enable_deletion_protection = false

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "Load balancer for ${var.environment} applications"
  }
}
