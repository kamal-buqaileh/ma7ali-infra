# PostgreSQL RDS configuration for staging environment
locals {
  # RDS configuration locals
  rds_identifier = "${var.project_name}-${var.environment}-db"
  database_name  = var.project_name
}

module "rds" {
  source = "../../modules/rds"

  # Basic configuration
  identifier      = local.rds_identifier
  database_name   = local.database_name
  master_username = var.db_master_username
  master_password = random_password.db_master_password.result

  # Network configuration
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.subnets.subnets_by_tier["Database"]

  # Allow access from private subnets (where EKS will run)
  allowed_cidr_blocks = [
    "10.0.10.0/24", # Private subnet 1
    "10.0.11.0/24"  # Private subnet 2
  ]

  # Instance configuration for staging
  instance_class        = "db.t3.micro" # Cost-effective for staging
  engine_version        = "15.4"
  allocated_storage     = 20    # Minimum for staging
  max_allocated_storage = 100   # Auto-scaling limit
  storage_type          = "gp2" # General purpose SSD

  # High availability (disabled for staging to save cost)
  multi_az = false

  # Backup configuration
  backup_retention_period = 7                     # 1 week retention
  backup_window           = "03:00-04:00"         # UTC backup window
  maintenance_window      = "sun:04:00-sun:05:00" # UTC maintenance window

  # Security configuration
  storage_encrypted = true
  kms_key_id        = module.main_kms_key.arn # Use main KMS key for storage

  # Staging-specific settings with security justifications
  deletion_protection                 = false # Allow deletion for staging environment
  iam_database_authentication_enabled = true  # Enable IAM database authentication

  # Secrets are now managed externally by the SSM module

  # Monitoring (basic for staging)
  performance_insights_enabled = false # Disable to save cost
  monitoring_interval          = 0     # No enhanced monitoring

  # CloudWatch logs
  enabled_cloudwatch_logs_exports = ["postgresql"]

  # Maintenance
  auto_minor_version_upgrade = true
  apply_immediately          = false

  # No read replica for staging
  create_read_replica = false

  # Custom parameter group for staging optimizations
  create_parameter_group = true
  parameter_group_family = "postgres15"
  parameters = [
    {
      name  = "shared_preload_libraries"
      value = "pg_stat_statements"
    },
    {
      name  = "log_statement"
      value = "mod" # Log modifications only
    },
    {
      name  = "log_min_duration_statement"
      value = "1000" # Log slow queries (1 second+)
    },
    {
      name  = "max_connections"
      value = "100" # Appropriate for t3.micro
    }
  ]

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "PostgreSQL database for staging applications"
    Backup      = "daily"
  }
}
