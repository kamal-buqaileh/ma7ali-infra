# KMS Module

A secure Terraform module for creating and managing AWS KMS keys with automatic rotation, proper policies, and comprehensive security features.

## 🎯 Features

- **Security-First Design**: Automatic key rotation and proper access policies
- **Flexible Configuration**: Configurable deletion windows and key states
- **Comprehensive Validation**: Input validation for all parameters
- **Tagging Support**: Full tagging support for resource management
- **Alias Management**: Automatic alias creation for easy reference
- **Production-Ready**: Enterprise-level security and compliance features

## 📋 Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

## 🔧 Usage

### Basic Usage

```hcl
module "kms_key" {
  source = "../../modules/kms"

  description = "Main encryption key for application"
  alias       = "main-key"
  
  enable_key_rotation = true
  deletion_window_in_days = 10
  is_enabled = true

  key_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Allow root account full access"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })

  tags = {
    Name        = "main-encryption-key"
    Environment = "staging"
    Purpose     = "Application encryption"
  }
}
```

### Production Usage with Granular Policies

```hcl
module "production_kms_key" {
  source = "../../modules/kms"

  description = "Production encryption key with granular access"
  alias       = "production-key"
  
  enable_key_rotation = true
  deletion_window_in_days = 30
  is_enabled = true

  key_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Allow root account full access"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow specific roles to use the key"
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/application-role"
          ]
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name        = "production-encryption-key"
    Environment = "production"
    Purpose     = "Production encryption"
    Compliance  = "SOX"
  }
}
```

## 📝 Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| description | Description of the KMS key | `string` | n/a | yes |
| alias | Alias for the KMS key (without 'alias/' prefix) | `string` | n/a | yes |
| enable_key_rotation | Enable automatic key rotation | `bool` | `true` | no |
| deletion_window_in_days | Number of days to wait before deleting the key | `number` | `10` | no |
| is_enabled | Whether the key is enabled for use | `bool` | `true` | no |
| key_policy | JSON-formatted IAM policy for the KMS key | `string` | n/a | yes |
| tags | Tags to apply to the KMS key | `map(string)` | `{}` | no |

## 📤 Outputs

| Name | Description |
|------|-------------|
| key_id | The globally unique identifier for the key |
| arn | The Amazon Resource Name (ARN) of the key |
| alias_name | The alias name of the key |
| alias_arn | The Amazon Resource Name (ARN) of the key alias |
| key_rotation_enabled | Whether key rotation is enabled |

## 🔒 Security Features

### Automatic Security Measures

- **Key Rotation**: Automatic key rotation enabled by default
- **Deletion Protection**: Configurable deletion window (7-30 days)
- **Access Control**: Proper IAM policies required
- **Alias Management**: Friendly names for easy reference

### Best Practices

- **Principle of Least Privilege**: Granular access policies
- **Key Rotation**: Automatic rotation for security compliance
- **Deletion Windows**: Prevents accidental key deletion
- **Tagging**: Comprehensive resource tagging

## 🏗️ Architecture

```
KMS Key
├── Key Configuration
│   ├── Description
│   ├── Key Rotation
│   ├── Deletion Window
│   └── Enabled State
├── Access Control
│   └── IAM Policy
├── Alias
│   └── Friendly Name
└── Tags
    └── Resource Management
```

## 🎯 Examples

### Development Environment

```hcl
module "dev_kms_key" {
  source = "../../modules/kms"

  description = "Development encryption key"
  alias       = "dev-key"
  
  # Development-specific settings
  deletion_window_in_days = 7
  enable_key_rotation = true
  
  key_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Allow root account full access"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })

  tags = {
    Name        = "dev-encryption-key"
    Environment = "development"
    Purpose     = "Development encryption"
  }
}
```

### Production Environment

```hcl
module "prod_kms_key" {
  source = "../../modules/kms"

  description = "Production encryption key"
  alias       = "prod-key"
  
  # Production-specific settings
  deletion_window_in_days = 30
  enable_key_rotation = true
  
  key_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Allow root account full access"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow application role access"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/application-role"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name        = "prod-encryption-key"
    Environment = "production"
    Purpose     = "Production encryption"
    Compliance  = "SOX"
  }
}
```

## 🔍 Validation

The module includes comprehensive input validation:

- **Description**: Must not be empty
- **Alias**: Must contain only alphanumeric characters, hyphens, underscores, and forward slashes
- **Deletion Window**: Must be between 7 and 30 days
- **Key Policy**: Must be valid JSON format

## 🚨 Important Notes

1. **Key Rotation**: Enabled by default for security compliance
2. **Deletion Window**: Set appropriately for your environment (7-30 days)
3. **Access Policies**: Always follow the principle of least privilege
4. **Aliases**: Provide friendly names for easier management
5. **Tags**: Use comprehensive tagging for resource management

## 🔄 Key Rotation

Automatic key rotation is enabled by default and:
- Rotates keys every 365 days
- Maintains backward compatibility
- Reduces manual key management overhead
- Improves security posture

## 📚 References

- [AWS KMS Documentation](https://docs.aws.amazon.com/kms/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key)
- [KMS Best Practices](https://docs.aws.amazon.com/kms/latest/developerguide/best-practices.html)
- [Key Rotation](https://docs.aws.amazon.com/kms/latest/developerguide/rotate-keys.html) 