# SSM (Secrets Manager) Module

This module provides centralized management of AWS Secrets Manager secrets for applications and infrastructure components.

## Features

- **Centralized Secret Management**: Manage all secrets from one place
- **Flexible Secret Types**: Support for JSON, string, and binary secrets
- **KMS Encryption**: All secrets encrypted with provided KMS key
- **Automatic Rotation**: Optional automatic secret rotation
- **Cross-Region Replication**: Optional secret replication to other regions
- **Lifecycle Management**: Configurable recovery windows and version stages

## Usage

### Basic Secret (String)
```hcl
module "ssm" {
  source = "../../modules/ssm"
  
  kms_key_arn = module.kms.key_arn
  
  secrets = {
    api_key = {
      name         = "my-app-api-key"
      description  = "API key for external service"
      secret_string = "your-api-key-here"
    }
  }
  
  tags = {
    Environment = "staging"
    Project     = "my-project"
  }
}
```

### Database Credentials (JSON)
```hcl
module "ssm" {
  source = "../../modules/ssm"
  
  kms_key_arn = module.kms.key_arn
  
  secrets = {
    db_credentials = {
      name        = "database-credentials"
      description = "Database connection credentials"
      secret_json = {
        username     = "dbuser"
        password     = "generated-password"
        database_url = "postgresql://user:pass@host:5432/db"
      }
    }
  }
}
```

### With Automatic Rotation
```hcl
module "ssm" {
  source = "../../modules/ssm"
  
  kms_key_arn = module.kms.key_arn
  
  secrets = {
    rotated_secret = {
      name        = "auto-rotated-secret"
      description = "Secret with automatic rotation"
      secret_string = "initial-value"
      
      rotation_config = {
        lambda_arn               = aws_lambda_function.rotation.arn
        automatically_after_days = 30
      }
    }
  }
}
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| secrets | Map of secrets to create | `map(object)` | `{}` | no |
| kms_key_arn | ARN of KMS key for encryption | `string` | n/a | yes |
| default_recovery_window_days | Default recovery window | `number` | `30` | no |
| tags | Common tags for all secrets | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| secret_arns | Map of secret keys to ARNs |
| secret_names | Map of secret keys to names |
| secret_ids | Map of secret keys to IDs |
| secret_arn_by_name | Map of secret names to ARNs |
| secret_version_ids | Map of secret keys to version IDs |

## Secret Configuration

Each secret in the `secrets` map supports:

- **name**: The name of the secret in AWS
- **description**: Human-readable description
- **secret_json**: JSON object for structured secrets (like DB credentials)
- **secret_string**: Simple string secrets
- **secret_binary**: Binary secrets (base64 encoded)
- **recovery_window_in_days**: Days to retain deleted secret (0-30)
- **policy**: Resource-based policy JSON
- **version_stages**: List of version stages
- **tags**: Additional tags for this secret
- **replicas**: Cross-region replication configuration
- **rotation_config**: Automatic rotation settings

## Examples

See the `environments/staging/ssm.tf` file for real-world usage examples.
