# CloudWatch Module

This module creates CloudWatch log groups and VPC flow logs for monitoring and logging purposes. It supports multiple log groups with configurable retention periods and VPC flow logs for network monitoring.

## Features

- ✅ **Multiple Log Groups**: Support for multiple CloudWatch log groups
- ✅ **VPC Flow Logs**: Optional VPC flow logs for network monitoring
- ✅ **Configurable Retention**: Configurable retention periods for log groups
- ✅ **IAM Integration**: Automatic IAM role and policy creation for flow logs
- ✅ **Tagging**: Comprehensive tagging support for resource management
- ✅ **Validation**: Input validation for naming conventions

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

## Usage

### Basic CloudWatch

```hcl
module "cloudwatch" {
  source = "../../modules/cloudwatch"

  name  = "my-project-staging"
  vpc_id = module.vpc.vpc_id

  enable_vpc_flow_logs = true
  flow_log_retention_days = 7

  log_groups = {
    application = {
      name              = "/aws/application/my-project-staging"
      retention_in_days = 7
      tags = {
        Purpose = "Application logs"
      }
    }
  }

  tags = {
    Environment = "staging"
    Project     = "my-project"
  }
}
```

### Advanced CloudWatch with Multiple Log Groups

```hcl
module "cloudwatch" {
  source = "../../modules/cloudwatch"

  name  = "my-project-production"
  vpc_id = module.vpc.vpc_id

  enable_vpc_flow_logs = true
  flow_log_retention_days = 30

  log_groups = {
    application = {
      name              = "/aws/application/my-project-production"
      retention_in_days = 30
      tags = {
        Purpose = "Application logs"
      }
    },
    security = {
      name              = "/aws/security/my-project-production"
      retention_in_days = 90
      tags = {
        Purpose = "Security logs"
      }
    },
    performance = {
      name              = "/aws/performance/my-project-production"
      retention_in_days = 7
      tags = {
        Purpose = "Performance logs"
      }
    }
  }

  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}
```

### CloudWatch without VPC Flow Logs

```hcl
module "cloudwatch" {
  source = "../../modules/cloudwatch"

  name  = "my-project-staging"

  log_groups = {
    application = {
      name              = "/aws/application/my-project-staging"
      retention_in_days = 7
      tags = {
        Purpose = "Application logs"
      }
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
| name | Name prefix for CloudWatch resources | `string` | n/a | yes |
| vpc_id | The ID of the VPC for flow logs | `string` | `null` | no |
| log_groups | Map of CloudWatch log groups to create | `map(object)` | `{}` | no |
| enable_vpc_flow_logs | Whether to enable VPC flow logs | `bool` | `false` | no |
| flow_log_retention_days | Retention period for VPC flow logs in days | `number` | `7` | no |
| tags | Tags to apply to all CloudWatch resources | `map(string)` | `{}` | no |

### Log Group Configuration Object

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| name | Name of the log group | `string` | yes |
| retention_in_days | Retention period in days | `number` | yes |
| tags | Tags specific to this log group | `map(string)` | no |

## Outputs

| Name | Description |
|------|-------------|
| log_group_names | Map of log group names |
| log_group_arns | Map of log group ARNs |
| flow_log_id | The ID of the VPC flow log |
| flow_log_arn | The ARN of the VPC flow log |

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    CloudWatch Module                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌───────────────┐│
│  │  Log Groups     │  │  VPC Flow Logs  │  │  IAM Role     ││
│  │                 │  │                 │  │               ││
│  │ • Application   │  │ • Network       │  │ • Flow Log    ││
│  │ • Security      │  │   Monitoring    │  │   Permissions ││
│  │ • Performance   │  │ • Traffic       │  │ • CloudWatch  ││
│  │                 │  │   Analysis      │  │   Access      ││
│  │ • Configurable  │  │ • Configurable  │  │               ││
│  │   Retention     │  │   Retention     │  │               ││
│  └─────────────────┘  └─────────────────┘  └───────────────┘│
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Security Features

- **VPC Flow Logs**: Network traffic monitoring for security analysis
- **IAM Integration**: Secure IAM role and policy for flow logs
- **Tagging**: Comprehensive resource tagging for cost tracking and management
- **Validation**: Input validation to prevent misconfigurations

## Important Notes

1. **VPC Flow Logs**: VPC flow logs are only created if `enable_vpc_flow_logs` is set to `true` and `vpc_id` is provided.

2. **Retention Periods**: Choose appropriate retention periods based on your compliance and cost requirements.

3. **Log Group Names**: Log group names should follow AWS naming conventions and be unique within your account.

4. **Cost Considerations**: VPC flow logs and log retention can incur costs, so plan accordingly.

## Related Modules

- **vpc**: The VPC for flow logs
- **iam_policies**: For additional IAM policies if needed

## Examples

See the `environments/staging/cloudwatch.tf` file for a complete example of how to use this module in a staging environment.
