# RDS PostgreSQL Module

This module creates a highly available and secure PostgreSQL RDS instance with best practices for production workloads.

## Features

- **Secure by Default**: Encrypted storage, private subnets, restricted security groups
- **High Availability**: Multi-AZ support with automatic failover
- **Automated Backups**: Configurable backup retention and maintenance windows
- **Performance Monitoring**: Performance Insights and enhanced monitoring
- **Secret Management**: Master password stored in AWS Secrets Manager
- **Read Replicas**: Optional read replicas for read-heavy workloads
- **Parameter/Option Groups**: Customizable database configuration

## Usage

### Basic PostgreSQL Instance

```hcl
module "rds" {
  source = "../../modules/rds"

  identifier      = "myapp-staging-db"
  database_name   = "myapp"
  master_username = "postgres"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.subnets.subnets_by_tier["Database"]
  allowed_cidr_blocks = [
    "10.0.10.0/24",  # Private subnets where EKS runs
    "10.0.11.0/24"
  ]

  # Instance configuration
  instance_class    = "db.t3.small"
  engine_version    = "15.4"
  allocated_storage = 50

  # High availability
  multi_az = true

  # Security
  storage_encrypted = true
  deletion_protection = true

  # Monitoring
  performance_insights_enabled = true
  monitoring_interval = 60

  tags = {
    Environment = "staging"
    Project     = "myapp"
  }
}
```

### Production Configuration with Read Replica

```hcl
module "rds" {
  source = "../../modules/rds"

  identifier      = "myapp-prod-db"
  database_name   = "myapp"
  master_username = "postgres"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.subnets.subnets_by_tier["Database"]
  allowed_cidr_blocks = ["10.0.10.0/24", "10.0.11.0/24"]

  # Production instance
  instance_class        = "db.r6g.large"
  engine_version        = "15.4"
  allocated_storage     = 200
  max_allocated_storage = 1000
  storage_type          = "gp3"

  # High availability
  multi_az = true

  # Backup configuration
  backup_retention_period = 30
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"

  # Security
  storage_encrypted   = true
  deletion_protection = true

  # Performance monitoring
  performance_insights_enabled          = true
  performance_insights_retention_period = 31
  monitoring_interval                   = 60

  # Read replica
  create_read_replica                           = true
  read_replica_instance_class                   = "db.r6g.large"
  read_replica_performance_insights_enabled     = true

  # Custom parameter group
  create_parameter_group = true
  parameters = [
    {
      name  = "shared_preload_libraries"
      value = "pg_stat_statements"
    },
    {
      name  = "log_statement"
      value = "all"
    }
  ]

  tags = {
    Environment = "production"
    Project     = "myapp"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| identifier | The name of the RDS instance | `string` | n/a | yes |
| vpc_id | ID of the VPC where the DB instance will be created | `string` | n/a | yes |
| subnet_ids | List of subnet IDs for the DB subnet group | `list(string)` | n/a | yes |
| allowed_cidr_blocks | List of CIDR blocks allowed to connect to the database | `list(string)` | `[]` | no |
| database_name | The name of the database to create | `string` | `null` | no |
| master_username | Username for the master DB user | `string` | `"postgres"` | no |
| instance_class | The instance type of the RDS instance | `string` | `"db.t3.micro"` | no |
| engine_version | The engine version to use | `string` | `"15.4"` | no |
| allocated_storage | The allocated storage in gigabytes | `number` | `20` | no |
| max_allocated_storage | The upper limit for automatic storage scaling | `number` | `100` | no |
| storage_type | Storage type (standard, gp2, gp3, io1) | `string` | `"gp2"` | no |
| storage_encrypted | Specifies whether the DB instance is encrypted | `bool` | `true` | no |
| multi_az | Specifies if the RDS instance is multi-AZ | `bool` | `false` | no |
| backup_retention_period | The days to retain backups for | `number` | `7` | no |
| deletion_protection | The database can't be deleted when this value is set to true | `bool` | `true` | no |
| performance_insights_enabled | Specifies whether Performance Insights are enabled | `bool` | `false` | no |
| monitoring_interval | The interval for collecting enhanced monitoring metrics | `number` | `0` | no |
| create_read_replica | Whether to create a read replica | `bool` | `false` | no |
| tags | A map of tags to assign to the resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| db_instance_id | The RDS instance ID |
| db_instance_arn | The ARN of the RDS instance |
| db_instance_endpoint | The RDS instance endpoint |
| db_instance_address | The RDS instance hostname |
| db_instance_port | The RDS instance port |
| db_instance_name | The database name |
| db_instance_password_secret_arn | The ARN of the Secrets Manager secret containing the database password |
| db_instance_password_secret_name | The name of the Secrets Manager secret containing the database password |
| db_security_group_id | The ID of the security group |
| connection_string | PostgreSQL connection string (without password) |
| jdbc_connection_string | JDBC connection string (without password) |

## Security

- **Encryption**: Storage encryption enabled by default
- **Network**: Database placed in private subnets, no public access
- **Access Control**: Security groups restrict access to specified CIDR blocks
- **Secrets**: Master password stored in AWS Secrets Manager
- **Backups**: Automated backups with configurable retention
- **Protection**: Deletion protection enabled by default

## Performance

- **Instance Classes**: Support for all RDS instance types
- **Storage**: GP2, GP3, and Provisioned IOPS storage options
- **Auto Scaling**: Storage auto-scaling to handle growth
- **Read Replicas**: Optional read replicas for read-heavy workloads
- **Performance Insights**: Detailed performance monitoring
- **Parameter Groups**: Custom PostgreSQL configuration

## High Availability

- **Multi-AZ**: Automatic failover to standby instance
- **Backups**: Point-in-time recovery up to 35 days
- **Maintenance**: Scheduled maintenance windows
- **Monitoring**: CloudWatch integration and enhanced monitoring

## Best Practices

1. **Use Multi-AZ** for production workloads
2. **Enable encryption** for sensitive data
3. **Set appropriate backup retention** (7+ days for production)
4. **Use Performance Insights** for monitoring
5. **Place in private subnets** with restricted security groups
6. **Use read replicas** for read-heavy applications
7. **Enable deletion protection** for production databases
