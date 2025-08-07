# IAM Groups Module

A secure Terraform module for creating and managing AWS IAM groups with MFA enforcement, flexible policy attachment, and comprehensive security features.

## 🎯 Features

- **Security-First Design**: Built-in MFA enforcement for enhanced security
- **Flexible Policy Attachment**: Dynamic policy attachment using maps
- **Comprehensive Validation**: Input validation for all parameters
- **Path Configuration**: Configurable group paths for organization
- **MFA Enforcement**: Conditional MFA enforcement for security compliance
- **Production-Ready**: Enterprise-level security and compliance features

## 📋 Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

## 🔧 Usage

### Basic Usage

```hcl
module "developer_group" {
  source = "../../modules/iam_groups"

  group_name = "developers"
  path       = "/"
  
  policy_arn_map = {
    s3  = module.s3_developer_policy.arn
    kms = module.kms_developer_policy.arn
  }
  
  enforce_mfa = true
}
```

### Advanced Usage with Multiple Policies

```hcl
module "admin_group" {
  source = "../../modules/iam_groups"

  group_name = "administrators"
  path       = "/admin/"
  
  policy_arn_map = {
    s3  = module.s3_admin_policy.arn
    kms = module.kms_admin_policy.arn
    iam = module.iam_admin_policy.arn
  }
  
  enforce_mfa = true
}
```

## 📝 Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| group_name | Name of the IAM group | `string` | n/a | yes |
| path | Path to the group | `string` | `"/"` | no |
| policy_arn_map | Map of policy ARNs to attach to the group | `map(string)` | n/a | yes |
| enforce_mfa | Whether to enforce MFA for this group | `bool` | `false` | no |

## 📤 Outputs

| Name | Description |
|------|-------------|
| group_name | The name of the IAM group |
| group_arn | The Amazon Resource Name (ARN) of the IAM group |
| group_id | The ID of the IAM group |
| group_path | The path of the IAM group |
| mfa_enforced | Whether MFA is enforced for this group |

## 🔒 Security Features

### Automatic Security Measures

- **MFA Enforcement**: Conditional MFA enforcement for enhanced security
- **Policy Attachment**: Flexible policy attachment using maps
- **Input Validation**: Comprehensive validation for all inputs
- **Path Organization**: Configurable paths for resource organization

### MFA Enforcement

When `enforce_mfa = true`, the module automatically creates an MFA enforcement policy that:

- **Denies all actions** except MFA-related ones when MFA is not present
- **Allows MFA setup** actions for users to configure MFA
- **Enforces security** across all group members
- **Complies with standards** for security and compliance

### Best Practices

- **Principle of Least Privilege**: Attach only necessary policies
- **MFA Enforcement**: Enable MFA for all groups in production
- **Path Organization**: Use paths to organize groups logically
- **Policy Management**: Use maps for flexible policy attachment

## 🏗️ Architecture

```
IAM Group
├── Group Configuration
│   ├── Name
│   ├── Path
│   └── MFA Enforcement
├── Policy Attachment
│   └── Dynamic Policy Map
├── Security
│   └── MFA Enforcement Policy
└── Validation
    ├── Name Validation
    ├── Path Validation
    └── Policy ARN Validation
```

## 🎯 Examples

### Development Group

```hcl
module "dev_group" {
  source = "../../modules/iam_groups"

  group_name = "developers"
  path       = "/developers/"
  
  policy_arn_map = {
    s3  = module.s3_developer_policy.arn
    kms = module.kms_developer_policy.arn
  }
  
  enforce_mfa = true
}
```

### Production Admin Group

```hcl
module "prod_admin_group" {
  source = "../../modules/iam_groups"

  group_name = "production-administrators"
  path       = "/admin/production/"
  
  policy_arn_map = {
    s3  = module.s3_admin_policy.arn
    kms = module.kms_admin_policy.arn
    iam = module.iam_admin_policy.arn
  }
  
  enforce_mfa = true
}
```

### Read-Only Group

```hcl
module "readonly_group" {
  source = "../../modules/iam_groups"

  group_name = "readonly-users"
  path       = "/readonly/"
  
  policy_arn_map = {
    s3  = module.s3_viewer_policy.arn
    kms = module.kms_viewer_policy.arn
  }
  
  enforce_mfa = false  # Optional for read-only access
}
```

## 🔍 Validation

The module includes comprehensive input validation:

- **Group Name**: Must contain only alphanumeric characters, hyphens, underscores, periods, @ symbols, plus signs, equals signs, and commas
- **Path**: Must start with a forward slash (/)
- **Policy ARNs**: Must be valid IAM policy ARNs

## 🚨 Important Notes

1. **MFA Enforcement**: Recommended for all groups in production environments
2. **Policy Attachment**: Use maps for flexible and maintainable policy attachment
3. **Path Organization**: Use paths to organize groups logically
4. **Security**: Always follow the principle of least privilege
5. **Validation**: All inputs are validated for security and compliance

## 🔐 MFA Enforcement Details

### MFA Policy Structure

When MFA enforcement is enabled, the module creates an inline policy with the following structure:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyAllExceptListedIfNoMFA",
      "Effect": "Deny",
      "NotAction": [
        "iam:CreateVirtualMFADevice",
        "iam:EnableMFADevice",
        "iam:GetUser",
        "iam:ListMFADevices",
        "iam:ListVirtualMFADevices",
        "iam:ResyncMFADevice",
        "iam:ChangePassword",
        "iam:GetAccountPasswordPolicy"
      ],
      "Resource": "*",
      "Condition": {
        "BoolIfExists": {
          "aws:MultiFactorAuthPresent": "false"
        }
      }
    }
  ]
}
```

### MFA Enforcement Benefits

- **Enhanced Security**: Prevents unauthorized access without MFA
- **Compliance**: Meets security and compliance requirements
- **User Experience**: Allows users to set up MFA when needed
- **Flexibility**: Can be enabled/disabled per group

## 📋 Group Organization

### Recommended Path Structure

```
/
├── /admin/           # Administrative groups
│   ├── /admin/production/
│   └── /admin/staging/
├── /developers/      # Developer groups
│   ├── /developers/senior/
│   └── /developers/junior/
├── /readonly/        # Read-only groups
└── /service/         # Service account groups
```

## 📚 References

- [AWS IAM Documentation](https://docs.aws.amazon.com/iam/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group)
- [IAM Groups](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_groups.html)
- [MFA Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_mfa.html) 