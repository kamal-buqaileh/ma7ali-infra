# S3 Module

A comprehensive Terraform module for creating and managing AWS S3 buckets with security best practices, encryption, logging, and lifecycle management.

## 🎯 Features

- **Security-First Design**: Private access, encryption, and public access blocking
- **Environment-Aware**: Conditional versioning for production environments
- **Comprehensive Logging**: Access logging for security and compliance
- **Lifecycle Management**: Configurable lifecycle rules for cost optimization
- **Encryption Support**: KMS or AES256 encryption
- **Input Validation**: Comprehensive validation for all inputs
- **Flexible Configuration**: Supports various use cases and requirements

## 📋 Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

## 🔧 Usage

### Basic Usage

```hcl
module "s3_bucket" {
  source = "../../modules/s3"

  bucket_prefix = "my-app"
  environment   = "staging"
  acl          = "private"
  
  enable_encryption = true
  enable_logging    = true
  force_destroy     = true

  tags = {
    Name        = "my-app-staging"
    Environment = "staging"
    Purpose     = "Application storage"
  }
}
```

### Production Usage with KMS Encryption

```hcl
module "s3_bucket" {
  source = "../../modules/s3"

  bucket_prefix = "my-app"
  environment   = "production"
  acl          = "private"
  
  enable_encryption = true
  kms_key_arn      = module.kms_key.arn
  enable_logging    = true
  force_destroy     = false

  lifecycle_rules = [
    {
      id              = "logs-lifecycle"
      status          = "Enabled"
      prefix          = "logs/"
      transition_days = 30
      storage_class   = "GLACIER"
      expiration_days = 90
    }
  ]

  tags = {
    Name        = "my-app-production"
    Environment = "production"
    Purpose     = "Application storage"
  }
}
```

## 📝 Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucket_prefix | Prefix for the S3 bucket name | `string` | n/a | yes |
| environment | Environment name (e.g. staging, production) | `string` | n/a | yes |
| acl | Canned ACL to apply | `string` | `"private"` | no |
| enable_versioning | Enable S3 bucket versioning | `bool` | `true` | no |
| enable_encryption | Enable AES256 encryption | `bool` | `true` | no |
| force_destroy | Allow destroy even if bucket is not empty | `bool` | `false` | no |
| enable_logging | Enable S3 bucket access logging | `bool` | `true` | no |
| logging_target_bucket | Target bucket for access logs | `string` | `null` | no |
| logging_target_prefix | Prefix for access logs | `string` | `"logs/"` | no |
| kms_key_arn | The KMS key ARN to use for bucket encryption | `string` | `null` | no |
| tags | Tags to apply to all resources | `map(string)` | `{}` | no |
| lifecycle_rules | List of lifecycle rules for the bucket | `list(object)` | `[]` | no |

### Lifecycle Rules Object

```hcl
object({
  id              = string
  status          = string
  prefix          = string
  transition_days = number
  storage_class   = string
  expiration_days = number
})
```

## 📤 Outputs

| Name | Description |
|------|-------------|
| bucket_name | The name of the bucket |
| bucket_arn | The ARN of the bucket |
| bucket_id | The ID of the bucket |
| bucket_region | The AWS region this bucket resides in |
| versioning_enabled | Whether versioning is enabled (only in production) |
| versioning_status | The versioning status of the bucket |

## 🔒 Security Features

### Automatic Security Measures

- **Public Access Blocking**: All public access is blocked by default
- **Server-Side Encryption**: AES256 or KMS encryption enabled by default
- **Access Logging**: Comprehensive logging for security and compliance
- **Private ACL**: Defaults to private access only

### Conditional Versioning

Versioning is automatically enabled only in production environments for:
- **Cost Optimization**: Reduces storage costs in staging/dev
- **Performance**: Faster operations in development environments
- **Environment Separation**: Different requirements for different environments

## 🏗️ Architecture

```
S3 Bucket
├── Encryption (AES256 or KMS)
├── Access Logging
├── Lifecycle Rules
├── Public Access Blocking
└── Conditional Versioning (Production Only)
```

## 🎯 Examples

### Staging Environment

```hcl
module "staging_bucket" {
  source = "../../modules/s3"

  bucket_prefix = "my-app"
  environment   = "staging"
  
  # Staging-specific settings
  force_destroy = true  # Allow easy cleanup
  enable_logging = true
  
  tags = {
    Name        = "my-app-staging"
    Environment = "staging"
    Purpose     = "Development storage"
  }
}
```

### Production Environment

```hcl
module "production_bucket" {
  source = "../../modules/s3"

  bucket_prefix = "my-app"
  environment   = "production"
  
  # Production-specific settings
  force_destroy = false  # Prevent accidental deletion
  kms_key_arn   = module.kms_key.arn
  enable_logging = true
  
  lifecycle_rules = [
    {
      id              = "archive-logs"
      status          = "Enabled"
      prefix          = "logs/"
      transition_days = 30
      storage_class   = "GLACIER"
      expiration_days = 365
    }
  ]

  tags = {
    Name        = "my-app-production"
    Environment = "production"
    Purpose     = "Production storage"
  }
}
```

## 🔍 Validation

The module includes comprehensive input validation:

- **Bucket Prefix**: Must contain only lowercase letters, numbers, and hyphens
- **Lifecycle Rules**: Transition and expiration days must be positive numbers
- **Environment**: Must be a valid environment name

## 🚨 Important Notes

1. **Versioning**: Only enabled in production environments for cost optimization
2. **Force Destroy**: Set to `true` in staging/dev, `false` in production
3. **Encryption**: Always enabled by default for security
4. **Logging**: Enabled by default for compliance and security
5. **Public Access**: Always blocked for security

## 📚 References

- [AWS S3 Documentation](https://docs.aws.amazon.com/s3/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)
- [S3 Security Best Practices](https://docs.aws.amazon.com/AmazonS3/latest/userguide/security-best-practices.html) 