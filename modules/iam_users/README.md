# IAM Users Module

A flexible Terraform module for creating and managing AWS IAM users with group membership, comprehensive tagging, and security best practices.

## 🎯 Features

- **Security-First Design**: Proper validation and security best practices
- **Flexible Group Assignment**: Multiple group memberships support
- **Comprehensive Validation**: Input validation for all parameters
- **Tagging Support**: Full tagging support for resource management
- **Path Configuration**: Configurable user paths for organization
- **Production-Ready**: Enterprise-level security and compliance features

## 📋 Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

## 🔧 Usage

### Basic Usage

```hcl
module "developer_user" {
  source = "../../modules/iam_users"

  user_name = "john.doe"
  path      = "/"
  
  group_names = [
    module.developer_group.group_name,
    module.s3_developer_group.group_name
  ]
  
  tags = {
    Name        = "john.doe"
    Environment = "staging"
    Purpose     = "Development"
    Role        = "Developer"
  }
}
```

### Advanced Usage with Multiple Groups

```hcl
module "admin_user" {
  source = "../../modules/iam_users"

  user_name = "admin.user"
  path      = "/admin/"
  
  group_names = [
    module.admin_group.group_name,
    module.s3_admin_group.group_name,
    module.kms_admin_group.group_name
  ]
  
  tags = {
    Name        = "admin.user"
    Environment = "production"
    Purpose     = "Administration"
    Role        = "Administrator"
    Compliance  = "SOX"
  }
}
```

## 📝 Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| user_name | The name of the IAM user | `string` | n/a | yes |
| path | Path to the user | `string` | `"/"` | no |
| group_names | List of IAM group names to assign to the user | `list(string)` | n/a | yes |
| tags | Tags to apply to the IAM user | `map(string)` | `{}` | no |

## 📤 Outputs

| Name | Description |
|------|-------------|
| user_name | The name of the IAM user |
| user_arn | The Amazon Resource Name (ARN) of the IAM user |
| user_id | The ID of the IAM user |
| user_path | The path of the IAM user |
| group_memberships | List of group names the user is a member of |

## 🔒 Security Features

### Automatic Security Measures

- **Input Validation**: Comprehensive validation for all inputs
- **Group Membership**: Flexible group assignment for permissions
- **Path Organization**: Configurable paths for resource organization
- **Tagging**: Comprehensive resource tagging for management

### Best Practices

- **Principle of Least Privilege**: Assign users to appropriate groups only
- **Group-Based Permissions**: Use groups for permission management
- **Path Organization**: Use paths to organize users logically
- **Tagging**: Use comprehensive tagging for resource management

## 🏗️ Architecture

```
IAM User
├── User Configuration
│   ├── Name
│   ├── Path
│   └── Tags
├── Group Membership
│   └── Dynamic Group Assignment
├── Validation
│   ├── Name Validation
│   ├── Path Validation
│   └── Group Name Validation
└── Resource Management
    └── Tagging System
```

## 🎯 Examples

### Developer User

```hcl
module "developer_user" {
  source = "../../modules/iam_users"

  user_name = "alice.smith"
  path      = "/developers/"
  
  group_names = [
    module.developer_group.group_name,
    module.s3_developer_group.group_name,
    module.kms_developer_group.group_name
  ]
  
  tags = {
    Name        = "alice.smith"
    Environment = "staging"
    Purpose     = "Development"
    Role        = "Developer"
    Team        = "Backend"
  }
}
```

### Production Admin User

```hcl
module "prod_admin_user" {
  source = "../../modules/iam_users"

  user_name = "admin.production"
  path      = "/admin/production/"
  
  group_names = [
    module.prod_admin_group.group_name,
    module.s3_admin_group.group_name,
    module.kms_admin_group.group_name,
    module.iam_admin_group.group_name
  ]
  
  tags = {
    Name        = "admin.production"
    Environment = "production"
    Purpose     = "Production Administration"
    Role        = "Administrator"
    Compliance  = "SOX"
  }
}
```

### Read-Only User

```hcl
module "readonly_user" {
  source = "../../modules/iam_users"

  user_name = "viewer.user"
  path      = "/readonly/"
  
  group_names = [
    module.readonly_group.group_name,
    module.s3_viewer_group.group_name
  ]
  
  tags = {
    Name        = "viewer.user"
    Environment = "staging"
    Purpose     = "Read-only access"
    Role        = "Viewer"
  }
}
```

## 🔍 Validation

The module includes comprehensive input validation:

- **User Name**: Must contain only alphanumeric characters, hyphens, underscores, periods, @ symbols, plus signs, equals signs, and commas
- **Path**: Must start with a forward slash (/)
- **Group Names**: Must contain only valid characters for IAM group names

## 🚨 Important Notes

1. **Group Membership**: Users inherit permissions from their group memberships
2. **Path Organization**: Use paths to organize users logically
3. **Security**: Always follow the principle of least privilege
4. **Tagging**: Use comprehensive tagging for resource management
5. **Validation**: All inputs are validated for security and compliance

## 📋 User Organization

### Recommended Path Structure

```
/
├── /admin/           # Administrative users
│   ├── /admin/production/
│   └── /admin/staging/
├── /developers/      # Developer users
│   ├── /developers/senior/
│   └── /developers/junior/
├── /readonly/        # Read-only users
└── /service/         # Service account users
```

## 🔐 Security Considerations

### User Management Best Practices

1. **Group-Based Permissions**: Always use groups for permission management
2. **Principle of Least Privilege**: Grant minimum required permissions
3. **Regular Review**: Regularly review user permissions and group memberships
4. **Access Rotation**: Implement access key rotation policies
5. **MFA Enforcement**: Ensure MFA is enabled for all users

### Group Membership Strategy

- **Primary Group**: Assign users to a primary group based on their role
- **Secondary Groups**: Add additional groups for specific permissions
- **Temporary Access**: Use temporary group memberships for project-based access
- **Regular Audits**: Regularly audit group memberships

## 🎯 Use Cases

### Development Team

```hcl
# Senior Developer
module "senior_dev" {
  source = "../../modules/iam_users"

  user_name = "senior.dev"
  path      = "/developers/senior/"
  
  group_names = [
    module.senior_developer_group.group_name,
    module.s3_developer_group.group_name,
    module.kms_developer_group.group_name
  ]
  
  tags = {
    Name        = "senior.dev"
    Environment = "staging"
    Purpose     = "Senior Development"
    Role        = "Senior Developer"
    Team        = "Backend"
  }
}
```

### Operations Team

```hcl
# Operations Engineer
module "ops_engineer" {
  source = "../../modules/iam_users"

  user_name = "ops.engineer"
  path      = "/operations/"
  
  group_names = [
    module.operations_group.group_name,
    module.s3_admin_group.group_name,
    module.kms_admin_group.group_name
  ]
  
  tags = {
    Name        = "ops.engineer"
    Environment = "production"
    Purpose     = "Operations"
    Role        = "Operations Engineer"
    Team        = "DevOps"
  }
}
```

## 📚 References

- [AWS IAM Documentation](https://docs.aws.amazon.com/iam/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user)
- [IAM Users](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users.html)
- [IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html) 