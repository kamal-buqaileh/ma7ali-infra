# ECS configuration for staging environment
# Uses separate modules for ECS cluster and EC2 capacity

# ECS Cluster
module "ecs" {
  source = "../../modules/ecs"

  cluster_name = "${var.project_name}-${var.environment}-cluster"
  kms_key_arn  = module.main_kms_key.arn

  # Logging configuration (cost-optimized for staging)
  log_retention_days        = 7     # Shorter retention for staging
  enable_container_insights = false # Disable for cost savings in staging

  # Capacity providers - prioritize cost-effective options
  capacity_providers = ["FARGATE_SPOT", "FARGATE", "${var.project_name}-${var.environment}-cluster-ec2"]
  default_capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE_SPOT"
      weight            = 100 # Prefer spot instances for cost savings
    }
  ]

  # Task definitions from separate file
  task_definitions = local.task_definitions

  # Services from separate file
  services = local.services

  tags = {
    Environment   = var.environment
    Project       = var.project_name
    Purpose       = "Container orchestration for ${var.environment} applications"
    ManagedBy     = "Terraform"
    Platform      = "ECS"
    CostOptimized = "spot-arm64-scaling-to-zero"
  }
}

# EC2 Capacity for ECS
module "ecs_ec2" {
  source = "../../modules/ecs_ec2"

  cluster_name          = "${var.project_name}-${var.environment}-cluster"
  vpc_id                = module.vpc.vpc_id
  vpc_cidr_block        = module.vpc.vpc_cidr_block
  subnet_ids            = module.subnets.subnets_by_tier["Private"]
  region                = var.aws_region
  kms_key_arn           = module.main_kms_key.arn
  instance_profile_name = aws_iam_instance_profile.ecs.name

  # Cost-optimized instance configuration
  instance_type    = "t4g.micro" # ARM64 for better price/performance
  ami_type         = "arm64"
  min_size         = 0 # Scale to zero for cost optimization
  max_size         = 5 # Limit maximum instances
  desired_capacity = 1 # Start with one instance

  # Storage configuration
  volume_size = 30    # Adequate storage
  volume_type = "gp3" # Latest generation storage

  # Capacity provider settings
  protect_from_scale_in  = false # Allow aggressive scaling
  target_capacity        = 70    # Lower target for cost savings
  enable_managed_scaling = true

  # Security configuration
  alb_security_group_ids = [module.alb.alb_security_group_id]
  key_name               = null # No SSH access for staging

  tags = {
    Environment   = var.environment
    Project       = var.project_name
    Purpose       = "ECS EC2 capacity for ${var.environment}"
    ManagedBy     = "Terraform"
    Platform      = "ECS-EC2"
    CostOptimized = "spot-arm64-scaling-to-zero"
  }
}

# IAM Instance Profile for ECS EC2 instances
resource "aws_iam_instance_profile" "ecs" {
  name = "${var.project_name}-${var.environment}-ecs-instance-profile"
  role = aws_iam_role.ecs_instance_role.name

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "ECS EC2 instance profile"
    Service     = "ECS"
  }
}

# Security Group Rule: Allow ECS instances to access RDS
resource "aws_security_group_rule" "ecs_to_rds" {
  description              = "Allow ECS instances to access RDS"
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = module.ecs_ec2.security_group_id
  security_group_id        = module.rds.db_security_group_id
}

# Cost optimization notes:
#
# ECS COST OPTIMIZATIONS:
# - ARM64 instances (t4g.micro - 20-40% cheaper than x86)
# - Fargate Spot (up to 70% cheaper than regular Fargate)
# - Scaling to zero (min_size = 0 for Auto Scaling Group)
# - Short log retention (7 days vs 14+ for production)
# - Container Insights disabled (saves monitoring costs)
# - Single task per service (adequate for staging)
# - GP3 storage (better price/performance than GP2)
#
# EXPECTED MONTHLY COSTS:
# - ECS Cluster: $0 (no control plane charges)
# - EC2 instances: ~$5-10/month (t4g.micro spot instances)
# - Fargate Spot: Pay per running task (~$0.01/vCPU/hour)
# - Total: ~$5-15/month vs $73+ for EKS
#
# SCALING BEHAVIOR:
# - Auto Scaling Group can scale to zero when no tasks
# - ECS will automatically place tasks on available capacity
# - Fargate Spot provides overflow capacity when needed
# - Cost scales with actual usage, not fixed infrastructure