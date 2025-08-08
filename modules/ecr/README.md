# ECR Module

This module creates AWS Elastic Container Registry (ECR) repositories with security best practices, encryption, lifecycle management, and image scanning capabilities. It supports multiple repositories with individual configurations for different services.

## Features

- ✅ **Multiple Repositories**: Support for multiple ECR repositories with individual configurations
- ✅ **Security Scanning**: Automatic image vulnerability scanning on push
- ✅ **Encryption Support**: KMS or AES256 encryption for images at rest
- ✅ **Lifecycle Management**: Configurable lifecycle policies for cost optimization
- ✅ **Image Tag Mutability**: Configurable tag mutability for security
- ✅ **Tagging**: Comprehensive tagging support for resource management
- ✅ **Validation**: Input validation for naming conventions
- ✅ **Force Delete**: Optional force delete for non-production environments

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

## Usage

### Basic ECR Setup

```hcl
module "ecr" {
  source = "../../modules/ecr"

  name_prefix = "my-project-staging"

  repositories = {
    backend = {
      image_tag_mutability = "IMMUTABLE"
      scan_on_push         = true
      encryption_type      = "KMS"
      force_delete         = true
      tags = { Service = "backend" }
    }
  }

  tags = {
    Environment = "staging"
    Project     = "my-project"
  }
}
```

### Advanced ECR with Multiple Repositories and Lifecycle Policies

```hcl
module "ecr" {
  source = "../../modules/ecr"

  name_prefix = "my-project-production"

  repositories = {
    backend = {
      image_tag_mutability = "IMMUTABLE"
      scan_on_push         = true
      encryption_type      = "KMS"
      kms_key_arn          = module.kms_key.arn
      force_delete         = false
      lifecycle_policy     = jsonencode({
        rules = [
          {
            rulePriority = 1
            description  = "Keep last 20 production images"
            selection = {
              tagStatus   = "tagged"
              tagPrefixList = ["v", "release"]
              countType   = "imageCountMoreThan"
              countNumber = 20
            }
            action = { type = "expire" }
          },
          {
            rulePriority = 2
            description  = "Delete untagged images after 1 day"
            selection = {
              tagStatus     = "untagged"
              countType     = "sinceImagePushed"
              countUnit     = "days"
              countNumber   = 1
            }
            action = { type = "expire" }
          }
        ]
      })
      tags = { Service = "backend" }
    },
    frontend = {
      image_tag_mutability = "IMMUTABLE"
      scan_on_push         = true
      encryption_type      = "KMS"
      kms_key_arn          = module.kms_key.arn
      force_delete         = false
      lifecycle_policy     = jsonencode({
        rules = [
          {
            rulePriority = 1
            description  = "Keep last 15 frontend images"
            selection = {
              tagStatus   = "any"
              countType   = "imageCountMoreThan"
              countNumber = 15
            }
            action = { type = "expire" }
          }
        ]
      })
      tags = { Service = "frontend" }
    }
  }

  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}
```

### ECR with AES256 Encryption (Cost-Optimized)

```hcl
module "ecr" {
  source = "../../modules/ecr"

  name_prefix = "my-project-staging"

  repositories = {
    api = {
      image_tag_mutability = "MUTABLE"
      scan_on_push         = true
      encryption_type      = "AES256"  # No KMS key required
      force_delete         = true
      tags = { Service = "api" }
    }
  }

  tags = {
    Environment = "staging"
    Project     = "my-project"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name_prefix | Prefix to use for ECR repository names | `string` | n/a | yes |
| repositories | Map of ECR repositories to create and their settings | `map(object)` | `{}` | no |
| tags | Common tags to apply to all repositories | `map(string)` | `{}` | no |

### Repository Configuration Object

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| image_tag_mutability | Tag mutability setting for the repository | `string` | `"IMMUTABLE"` | no |
| scan_on_push | Indicates whether images are scanned after being pushed | `bool` | `true` | no |
| encryption_type | Encryption type to use for the repository | `string` | `"KMS"` | no |
| kms_key_arn | KMS key ARN to use for encryption (required if encryption_type is KMS and using CMK) | `string` | `null` | no |
| force_delete | Allow deletion of repositories containing images | `bool` | `false` | no |
| lifecycle_policy | JSON string containing the lifecycle policy | `string` | `null` | no |
| tags | Tags specific to this repository | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| repository_arns | Map of ECR repository ARNs |
| repository_urls | Map of ECR repository URLs |

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        ECR Module                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌───────────────┐│
│  │  Repository 1   │  │  Repository 2   │  │  Repository N ││
│  │                 │  │                 │  │               ││
│  │ • Image Scanning│  │ • Image Scanning│  │ • Image       ││
│  │ • KMS/AES256    │  │ • KMS/AES256    │  │   Scanning    ││
│  │   Encryption    │  │   Encryption    │  │ • Encryption  ││
│  │ • Tag Mutability│  │ • Tag Mutability│  │ • Lifecycle   ││
│  │ • Lifecycle     │  │ • Lifecycle     │  │   Policies    ││
│  │   Policies      │  │   Policies      │  │               ││
│  └─────────────────┘  └─────────────────┘  └───────────────┘│
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Security Features

### Automatic Security Measures

- **Image Scanning**: Vulnerability scanning enabled by default on image push
- **Encryption at Rest**: KMS or AES256 encryption for stored images
- **Tag Immutability**: Prevents image tag overwriting (configurable)
- **Access Control**: Works with IAM policies for fine-grained access control

### Encryption Options

- **KMS Encryption**: Use AWS KMS for encryption with customer-managed keys
- **AES256 Encryption**: Use AWS-managed encryption for cost optimization
- **Environment-Based**: Choose encryption type based on environment requirements

## Important Notes

1. **Encryption Type**: 
   - Use KMS with customer-managed keys for production environments
   - Use AES256 for staging/development to reduce costs [[memory:5581397]]

2. **Tag Mutability**: 
   - Set to `IMMUTABLE` for production to prevent tag overwriting
   - Can be `MUTABLE` for development environments

3. **Force Delete**: 
   - Set to `true` only in non-production environments
   - Always `false` in production to prevent accidental data loss

4. **Lifecycle Policies**: 
   - Use lifecycle policies to manage storage costs
   - Consider different retention rules for tagged vs untagged images

5. **Image Scanning**: 
   - Enabled by default for security
   - Results available in AWS Console and via API

## Cost Optimization

- **Lifecycle Policies**: Automatically delete old images to reduce storage costs
- **Encryption Choice**: Use AES256 in staging, KMS in production
- **Image Cleanup**: Regular cleanup of untagged and old images

## Related Modules

- **kms**: For customer-managed KMS keys for ECR encryption
- **iam_policies**: For ECR access policies and cross-account access

## Examples

See the `environments/staging/ecr.tf` file for a complete example of how to use this module in a staging environment with multiple repositories and lifecycle policies.

## References

- [AWS ECR Documentation](https://docs.aws.amazon.com/ecr/)
- [ECR Lifecycle Policies](https://docs.aws.amazon.com/AmazonECR/latest/userguide/LifecyclePolicies.html)
- [ECR Security Best Practices](https://docs.aws.amazon.com/AmazonECR/latest/userguide/security-best-practices.html)