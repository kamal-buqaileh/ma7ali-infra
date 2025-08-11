# RDS PostgreSQL module

# Random password for database
resource "random_password" "master_password" {
  length  = 32
  special = true
}

# Store password in AWS Secrets Manager
resource "aws_secretsmanager_secret" "db_password" {
  name                    = "${var.identifier}-master-password"
  description             = "Master password for ${var.identifier} RDS instance"
  recovery_window_in_days = var.deletion_protection ? 30 : 0
  kms_key_id             = var.secrets_kms_key_id
  policy                 = var.secrets_resource_policy

  tags = merge(var.tags, {
    Name = "${var.identifier}-master-password"
  })
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    username = var.master_username
    password = random_password.master_password.result
  })
}

# DB subnet group
resource "aws_db_subnet_group" "this" {
  name       = "${var.identifier}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${var.identifier}-subnet-group"
  })
}

# Security group for RDS
resource "aws_security_group" "rds" {
  name_prefix = "${var.identifier}-rds-"
  description = "Security group for RDS PostgreSQL instance"
  vpc_id      = var.vpc_id

  # PostgreSQL inbound from application subnets
  ingress {
    description = "PostgreSQL from application subnets"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  # No outbound rules needed for RDS
  egress {
    description = "No outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = []
  }

  tags = merge(var.tags, {
    Name = "${var.identifier}-rds-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# DB parameter group
resource "aws_db_parameter_group" "this" {
  count  = var.create_parameter_group ? 1 : 0
  family = var.parameter_group_family
  name   = "${var.identifier}-params"

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = merge(var.tags, {
    Name = "${var.identifier}-params"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# DB option group
resource "aws_db_option_group" "this" {
  count                    = var.create_option_group ? 1 : 0
  name                     = "${var.identifier}-options"
  option_group_description = "Option group for ${var.identifier}"
  engine_name              = "postgres"
  major_engine_version     = var.major_engine_version

  dynamic "option" {
    for_each = var.options
    content {
      option_name = option.value.option_name

      dynamic "option_settings" {
        for_each = lookup(option.value, "option_settings", [])
        content {
          name  = option_settings.value.name
          value = option_settings.value.value
        }
      }
    }
  }

  tags = merge(var.tags, {
    Name = "${var.identifier}-options"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# RDS instance
resource "aws_db_instance" "this" {
  # Basic configuration
  identifier     = var.identifier
  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  # Database configuration
  db_name  = var.database_name
  username = var.master_username
  password = random_password.master_password.result

  # Storage configuration
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = var.storage_encrypted
  kms_key_id           = var.kms_key_id

  # Network & Security
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false

  # Parameter and option groups
  parameter_group_name = var.create_parameter_group ? aws_db_parameter_group.this[0].name : var.parameter_group_name
  option_group_name    = var.create_option_group ? aws_db_option_group.this[0].name : var.option_group_name

  # Backup configuration
  backup_retention_period = var.backup_retention_period
  backup_window          = var.backup_window
  copy_tags_to_snapshot  = true
  delete_automated_backups = !var.deletion_protection

  # Maintenance
  maintenance_window         = var.maintenance_window
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  apply_immediately         = var.apply_immediately

  # Monitoring
  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_interval > 0 ? var.monitoring_role_arn : null
  
  # tfsec:ignore:aws-rds-enable-performance-insights
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null
  performance_insights_kms_key_id      = var.performance_insights_enabled ? var.performance_insights_kms_key_id : null

  # High Availability
  multi_az               = var.multi_az
  availability_zone      = var.multi_az ? null : var.availability_zone

  # Protection - Allow override for staging environments
  # tfsec:ignore:aws-rds-enable-deletion-protection
  deletion_protection = var.deletion_protection
  skip_final_snapshot = !var.deletion_protection
  final_snapshot_identifier = var.deletion_protection ? "${var.identifier}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}" : null

  # IAM database authentication
  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  # Logging
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  tags = merge(var.tags, {
    Name = var.identifier
  })

  depends_on = [
    aws_secretsmanager_secret_version.db_password
  ]

  lifecycle {
    ignore_changes = [
      password,
      final_snapshot_identifier,
    ]
  }
}

# Read replica (optional)
resource "aws_db_instance" "read_replica" {
  count = var.create_read_replica ? 1 : 0

  identifier = "${var.identifier}-read-replica"
  
  # Read replica configuration
  replicate_source_db = aws_db_instance.this.identifier
  instance_class      = var.read_replica_instance_class

  # Override settings for read replica
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.rds.id]

  # Monitoring for read replica
  monitoring_interval = var.read_replica_monitoring_interval
  monitoring_role_arn = var.read_replica_monitoring_interval > 0 ? var.monitoring_role_arn : null

  performance_insights_enabled          = var.read_replica_performance_insights_enabled
  performance_insights_retention_period = var.read_replica_performance_insights_enabled ? var.performance_insights_retention_period : null

  # Protection
  deletion_protection = var.deletion_protection
  skip_final_snapshot = !var.deletion_protection

  tags = merge(var.tags, {
    Name = "${var.identifier}-read-replica"
  })
}
