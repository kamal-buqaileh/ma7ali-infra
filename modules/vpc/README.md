# VPC Module

This module creates a simple VPC with DNS support enabled. It's designed to be the foundation for your infrastructure and can be extended with subnets, routes, gateways, and other networking components.

## Features

- ✅ **VPC Creation**: Creates a VPC with DNS support enabled
- ✅ **DNS Support**: Enables DNS hostnames and DNS resolution
- ✅ **Tagging**: Comprehensive tagging support for resource management
- ✅ **Validation**: Input validation for VPC CIDR and naming conventions
- ✅ **Modular Design**: Simple and focused - other components (subnets, routes, gateways) are separate modules

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

## Usage

### Basic VPC

```hcl
module "vpc" {
  source = "../../modules/vpc"

  name      = "my-project-staging"
  vpc_cidr  = "10.0.0.0/16"

  tags = {
    Name        = "my-project-staging-vpc"
    Environment = "staging"
    Purpose     = "Main VPC"
  }
}
```

### Advanced VPC with Custom Tags

```hcl
module "vpc" {
  source = "../../modules/vpc"

  name      = "my-project-production"
  vpc_cidr  = "172.16.0.0/16"

  tags = {
    Name        = "my-project-production-vpc"
    Environment = "production"
    Purpose     = "Main VPC"
    Owner       = "DevOps Team"
    CostCenter  = "IT-001"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the VPC | `string` | n/a | yes |
| vpc_cidr | CIDR block for the VPC | `string` | n/a | yes |
| tags | Tags to apply to the VPC | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | The ID of the VPC |
| vpc_arn | The ARN of the VPC |
| vpc_cidr_block | The CIDR block of the VPC |

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        VPC Module                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────┐                                        │
│  │       VPC       │                                        │
│  │                 │                                        │
│  │ • DNS Support   │                                        │
│  │ • DNS Hostnames │                                        │
│  │ • CIDR Block    │                                        │
│  └─────────────────┘                                        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Security Features

- **DNS Support**: Enables DNS hostnames and DNS resolution
- **Tagging**: Comprehensive resource tagging for cost tracking and management
- **Validation**: Input validation to prevent misconfigurations

## Important Notes

1. **Modular Design**: This module only creates the VPC. Subnets, routes, gateways, and other networking components should be created using separate modules.

2. **CIDR Planning**: Choose your VPC CIDR carefully as it cannot be changed after creation. Consider future growth and subnet requirements.

3. **DNS Support**: DNS support is enabled by default for better service discovery and connectivity.

4. **Gateway Separation**: Internet Gateways, NAT Gateways, and VPC Endpoints are now handled by the separate `gateways` module for better flexibility and cost control.

## Related Modules

- **gateways**: For creating Internet Gateways, NAT Gateways, and VPC Endpoints
- **subnets**: For creating subnets within the VPC
- **routes**: For creating route tables and routes
- **cloudwatch**: For VPC flow logs and monitoring
- **security_groups**: For network security rules

## Examples

See the `environments/staging/vpc.tf` file for a complete example of how to use this module in a staging environment.
