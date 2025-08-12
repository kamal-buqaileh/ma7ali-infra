# RDS module outputs

output "db_instance_id" {
  description = "The RDS instance ID"
  value       = aws_db_instance.this.id
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = aws_db_instance.this.arn
}

output "db_instance_endpoint" {
  description = "The RDS instance endpoint"
  value       = aws_db_instance.this.endpoint
}

output "db_instance_address" {
  description = "The RDS instance hostname"
  value       = aws_db_instance.this.address
}

output "db_instance_port" {
  description = "The RDS instance port"
  value       = aws_db_instance.this.port
}

output "db_instance_name" {
  description = "The database name"
  value       = aws_db_instance.this.db_name
}

output "db_instance_username" {
  description = "The master username for the database"
  value       = aws_db_instance.this.username
  sensitive   = true
}

# Secrets are now managed externally by the SSM module
# Use module.ssm.secret_arns["database_credentials"] to get the secret ARN

output "db_instance_engine" {
  description = "The database engine"
  value       = aws_db_instance.this.engine
}

output "db_instance_engine_version" {
  description = "The running version of the database"
  value       = aws_db_instance.this.engine_version_actual
}

output "db_instance_class" {
  description = "The RDS instance class"
  value       = aws_db_instance.this.instance_class
}

output "db_instance_status" {
  description = "The RDS instance status"
  value       = aws_db_instance.this.status
}

output "db_instance_availability_zone" {
  description = "The availability zone of the RDS instance"
  value       = aws_db_instance.this.availability_zone
}

output "db_instance_multi_az" {
  description = "If the RDS instance is multi AZ enabled"
  value       = aws_db_instance.this.multi_az
}

output "db_instance_backup_retention_period" {
  description = "The backup retention period"
  value       = aws_db_instance.this.backup_retention_period
}

output "db_instance_backup_window" {
  description = "The backup window"
  value       = aws_db_instance.this.backup_window
}

output "db_instance_maintenance_window" {
  description = "The instance maintenance window"
  value       = aws_db_instance.this.maintenance_window
}

# Security Group
output "db_security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.rds.id
}

output "db_security_group_arn" {
  description = "The ARN of the security group"
  value       = aws_security_group.rds.arn
}

# Subnet Group
output "db_subnet_group_id" {
  description = "The db subnet group name"
  value       = aws_db_subnet_group.this.id
}

output "db_subnet_group_arn" {
  description = "The ARN of the db subnet group"
  value       = aws_db_subnet_group.this.arn
}

# Parameter Group
output "db_parameter_group_id" {
  description = "The db parameter group id"
  value       = var.create_parameter_group ? aws_db_parameter_group.this[0].id : null
}

output "db_parameter_group_arn" {
  description = "The ARN of the db parameter group"
  value       = var.create_parameter_group ? aws_db_parameter_group.this[0].arn : null
}

# Option Group
output "db_option_group_id" {
  description = "The db option group id"
  value       = var.create_option_group ? aws_db_option_group.this[0].id : null
}

output "db_option_group_arn" {
  description = "The ARN of the db option group"
  value       = var.create_option_group ? aws_db_option_group.this[0].arn : null
}

# Read Replica
output "db_read_replica_id" {
  description = "The RDS read replica instance ID"
  value       = var.create_read_replica ? aws_db_instance.read_replica[0].id : null
}

output "db_read_replica_arn" {
  description = "The ARN of the RDS read replica instance"
  value       = var.create_read_replica ? aws_db_instance.read_replica[0].arn : null
}

output "db_read_replica_endpoint" {
  description = "The RDS read replica instance endpoint"
  value       = var.create_read_replica ? aws_db_instance.read_replica[0].endpoint : null
}

output "db_read_replica_address" {
  description = "The RDS read replica instance hostname"
  value       = var.create_read_replica ? aws_db_instance.read_replica[0].address : null
}

# Connection Information
output "connection_string" {
  description = "PostgreSQL connection string (without password)"
  value       = "postgresql://${aws_db_instance.this.username}@${aws_db_instance.this.endpoint}/${aws_db_instance.this.db_name}"
  sensitive   = true
}

output "jdbc_connection_string" {
  description = "JDBC connection string (without password)"
  value       = "jdbc:postgresql://${aws_db_instance.this.endpoint}:${aws_db_instance.this.port}/${aws_db_instance.this.db_name}"
}
