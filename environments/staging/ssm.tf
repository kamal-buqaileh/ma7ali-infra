# Secrets Manager configuration for staging environment
# Centralized management of all secrets used by applications and infrastructure

module "ssm" {
  source = "../../modules/ssm"

  kms_key_arn                  = module.main_kms_key.arn
  default_recovery_window_days = 0 # No recovery window for staging (immediate deletion)

  secrets = {
    # Database credentials for RDS
    database_credentials = {
      name        = "${var.project_name}-${var.environment}-database-credentials"
      description = "Database connection credentials for ${var.project_name} ${var.environment}"

      # Store both individual credentials and full connection string
      secret_json = {
        username     = var.db_master_username
        password     = random_password.db_master_password.result
        host         = module.rds.db_instance_endpoint
        port         = "5432"
        database     = var.db_name
        database_url = "postgresql://${var.db_master_username}:${random_password.db_master_password.result}@${module.rds.db_instance_endpoint}:5432/${var.db_name}"
      }

      tags = {
        Purpose = "Database connection credentials"
        Service = "RDS"
      }
    }

    # Example: API Keys (add as needed)
    # api_keys = {
    #   name        = "${var.project_name}-${var.environment}-api-keys"
    #   description = "External API keys for ${var.project_name} ${var.environment}"
    #   
    #   secret_json = {
    #     stripe_secret_key    = "sk_test_..."
    #     sendgrid_api_key    = "SG...."
    #     jwt_secret          = "your-jwt-secret"
    #   }
    #   
    #   tags = {
    #     Purpose = "Application API keys"
    #     Service = "Application"
    #   }
    # }
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "Centralized secret management for ${var.environment}"
    ManagedBy   = "Terraform"
    Service     = "SecretsManager"
  }
}

# Generate random password for database (moved from RDS module)
resource "random_password" "db_master_password" {
  length  = 32
  special = true
}

# Add variables for database configuration
variable "db_master_username" {
  description = "Master username for the database"
  type        = string
  default     = "postgres"
}

variable "db_name" {
  description = "Name of the database to create"
  type        = string
  default     = "ma7ali"
}
