# IAM Policies Module

A flexible Terraform module for creating and managing AWS IAM policies with comprehensive validation, tagging support, and security best practices.

## 🎯 Features

- **Security-First Design**: Proper validation and security best practices
- **Flexible Configuration**: Supports any IAM policy structure
- **Comprehensive Validation**: Input validation for all parameters
- **Tagging Support**: Full tagging support for resource management
- **Path Configuration**: Configurable policy paths for organization
- **Production-Ready**: Enterprise-level security and compliance features

## 📋 Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

## 🔧 Usage

### Basic Usage

```hcl
module "s3_read_policy" {
  source = "../../modules/iam_policies"

  name        = "s3-read-policy"
  description = "Read-only access to S3 buckets"
  path        = "/"
  
  policy_document = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::my-bucket",
          "arn:aws:s3:::my-bucket/*"
        ]
      }
    ]
  }

  tags = {
    Name        = "s3-read-policy"
    Environment = "staging"
    Purpose     = "S3 read access"
  }
}
```

### Advanced Usage with Multiple Statements

```hcl
module "admin_policy" {
  source = "../../modules/iam_policies"

  name        = "admin-policy"
  description = "Administrative access policy"
  path        = "/admin/"
  
  policy_document = {
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowS3Access"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::my-bucket",
          "arn:aws:s3:::my-bucket/*"
        ]
      },
      {
        Sid    = "AllowKMSAccess"
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "arn:aws:kms:region:account:key/key-id"
      }
    ]
  }

  tags = {
    Name        = "admin-policy"
    Environment = "production"
    Purpose     = "Administrative access"
    Compliance  = "SOX"
  }
}
```

## 📝 Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the IAM policy | `string` | n/a | yes |
| description | Description of the IAM policy | `string` | n/a | yes |
| path | Path to the policy | `string` | `"/"` | no |
| policy_document | IAM policy document as JSON object | `any` | n/a | yes |
| tags | Tags to apply to the IAM policy | `map(string)` | `{}` | no |

## 📤 Outputs

| Name | Description |
|------|-------------|
| arn | The Amazon Resource Name (ARN) of the created IAM policy |
| id | The ID of the IAM policy |
| name | The name of the IAM policy |
| path | The path of the IAM policy |
| policy_id | The ID of the policy |

## 🔒 Security Features

### Automatic Security Measures

- **Input Validation**: Comprehensive validation for all inputs
- **Policy Structure**: Ensures valid JSON policy structure
- **Naming Conventions**: Enforces proper naming conventions
- **Path Validation**: Ensures proper path structure

### Best Practices

- **Principle of Least Privilege**: Grant minimum required permissions
- **Resource Scoping**: Scope resources to specific ARNs
- **Conditional Access**: Use conditions for additional security
- **Tagging**: Comprehensive resource tagging

## 🏗️ Architecture

```
IAM Policy
├── Policy Configuration
│   ├── Name
│   ├── Description
│   ├── Path
│   └── Policy Document
├── Access Control
│   └── JSON Policy Structure
├── Validation
│   ├── Name Validation
│   ├── Path Validation
│   └── Policy Validation
└── Tags
    └── Resource Management
```

## 🎯 Examples

### S3 Access Policy

```hcl
module "s3_access_policy" {
  source = "../../modules/iam_policies"

  name        = "s3-access-policy"
  description = "S3 bucket access policy"
  path        = "/s3/"
  
  policy_document = {
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowBucketAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::my-bucket/*"
        ]
      },
      {
        Sid    = "AllowBucketListing"
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::my-bucket"
        ]
      }
    ]
  }

  tags = {
    Name        = "s3-access-policy"
    Environment = "staging"
    Purpose     = "S3 access"
    Service     = "S3"
  }
}
```

### KMS Access Policy

```hcl
module "kms_access_policy" {
  source = "../../modules/iam_policies"

  name        = "kms-access-policy"
  description = "KMS key access policy"
  path        = "/kms/"
  
  policy_document = {
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowKMSAccess"
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ]
        Resource = [
          "arn:aws:kms:region:account:key/key-id"
        ]
      }
    ]
  }

  tags = {
    Name        = "kms-access-policy"
    Environment = "production"
    Purpose     = "KMS access"
    Service     = "KMS"
  }
}
```

### Conditional Access Policy

```hcl
module "conditional_policy" {
  source = "../../modules/iam_policies"

  name        = "conditional-policy"
  description = "Policy with conditional access"
  path        = "/conditional/"
  
  policy_document = {
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowConditionalAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = [
          "arn:aws:s3:::my-bucket/*"
        ]
        Condition = {
          StringEquals = {
            "aws:RequestedRegion" = ["us-east-1"]
          }
        }
      }
    ]
  }

  tags = {
    Name        = "conditional-policy"
    Environment = "production"
    Purpose     = "Conditional access"
  }
}
```

## 🔍 Validation

The module includes comprehensive input validation:

- **Name**: Must contain only alphanumeric characters, hyphens, underscores, periods, @ symbols, plus signs, equals signs, and commas
- **Description**: Must not be empty
- **Path**: Must start with a forward slash (/)
- **Policy Document**: Must be valid JSON format

## 🚨 Important Notes

1. **Policy Structure**: Always follow AWS IAM policy structure
2. **Resource Scoping**: Scope resources to specific ARNs when possible
3. **Principle of Least Privilege**: Grant minimum required permissions
4. **Conditions**: Use conditions for additional security controls
5. **Tags**: Use comprehensive tagging for resource management

## 📋 Policy Structure

### Basic Policy Structure

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "StatementName",
      "Effect": "Allow",
      "Action": [
        "service:Action"
      ],
      "Resource": [
        "arn:aws:service:region:account:resource"
      ]
    }
  ]
}
```

### Policy with Conditions

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ConditionalAccess",
      "Effect": "Allow",
      "Action": [
        "service:Action"
      ],
      "Resource": [
        "arn:aws:service:region:account:resource"
      ],
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": ["us-east-1"]
        }
      }
    }
  ]
}
```

## 📚 References

- [AWS IAM Documentation](https://docs.aws.amazon.com/iam/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)
- [IAM Policy Structure](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html)
- [IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html) 