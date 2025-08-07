# Subnets Module

This module creates subnets within a VPC. It supports multiple subnet types (public, private, database) and can create subnets across multiple availability zones.

## Features

- ✅ **Multiple Subnet Types**: Support for public, private, and database subnets
- ✅ **Multi-AZ Support**: Create subnets across multiple availability zones
- ✅ **Flexible Configuration**: Configurable CIDR blocks, availability zones, and tags
- ✅ **Tier-based Organization**: Subnets are organized by tier (Public, Private, Database)
- ✅ **Tagging**: Comprehensive tagging support for resource management
- ✅ **Validation**: Input validation for naming conventions

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

## Usage

### Basic Subnets

```hcl
module "subnets" {
  source = "../../modules/subnets"

  name   = "my-project-staging"
  vpc_id = module.vpc.vpc_id

  subnets = [
    {
      cidr_block              = "10.0.1.0/24"
      availability_zone       = "us-west-2a"
      tier                    = "Public"
      map_public_ip_on_launch = true
      tags = {
        Purpose = "Public subnets for ALB"
      }
    },
    {
      cidr_block              = "10.0.2.0/24"
      availability_zone       = "us-west-2b"
      tier                    = "Private"
      map_public_ip_on_launch = false
      tags = {
        Purpose = "Private subnets for EKS"
      }
    },
    {
      cidr_block              = "10.0.3.0/24"
      availability_zone       = "us-west-2a"
      tier                    = "Database"
      map_public_ip_on_launch = false
      tags = {
        Purpose = "Database subnets for RDS"
      }
    }
  ]

  tags = {
    Environment = "staging"
    Project     = "my-project"
  }
}
```

### Multi-AZ Subnets

```hcl
module "subnets" {
  source = "../../modules/subnets"

  name   = "my-project-production"
  vpc_id = module.vpc.vpc_id

  subnets = [
    # Public subnets
    {
      cidr_block              = "10.0.1.0/24"
      availability_zone       = "us-west-2a"
      tier                    = "Public"
      map_public_ip_on_launch = true
      tags = { Purpose = "Public subnet AZ-a" }
    },
    {
      cidr_block              = "10.0.2.0/24"
      availability_zone       = "us-west-2b"
      tier                    = "Public"
      map_public_ip_on_launch = true
      tags = { Purpose = "Public subnet AZ-b" }
    },
    # Private subnets
    {
      cidr_block              = "10.0.10.0/24"
      availability_zone       = "us-west-2a"
      tier                    = "Private"
      map_public_ip_on_launch = false
      tags = { Purpose = "Private subnet AZ-a" }
    },
    {
      cidr_block              = "10.0.11.0/24"
      availability_zone       = "us-west-2b"
      tier                    = "Private"
      map_public_ip_on_launch = false
      tags = { Purpose = "Private subnet AZ-b" }
    },
    # Database subnets
    {
      cidr_block              = "10.0.20.0/24"
      availability_zone       = "us-west-2a"
      tier                    = "Database"
      map_public_ip_on_launch = false
      tags = { Purpose = "Database subnet AZ-a" }
    },
    {
      cidr_block              = "10.0.21.0/24"
      availability_zone       = "us-west-2b"
      tier                    = "Database"
      map_public_ip_on_launch = false
      tags = { Purpose = "Database subnet AZ-b" }
    }
  ]

  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name prefix for the subnets | `string` | n/a | yes |
| vpc_id | The ID of the VPC | `string` | n/a | yes |
| subnets | List of subnet configurations | `list(object)` | n/a | yes |
| tags | Tags to apply to all subnets | `map(string)` | `{}` | no |

### Subnet Configuration Object

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| cidr_block | CIDR block for the subnet | `string` | yes |
| availability_zone | Availability zone for the subnet | `string` | yes |
| tier | Tier of the subnet (Public, Private, Database) | `string` | yes |
| map_public_ip_on_launch | Whether to auto-assign public IPs | `bool` | yes |
| tags | Tags specific to this subnet | `map(string)` | no |

## Outputs

| Name | Description |
|------|-------------|
| subnet_ids | List of subnet IDs |
| subnet_arns | List of subnet ARNs |
| subnet_cidr_blocks | List of subnet CIDR blocks |
| subnets_by_tier | Map of subnet IDs grouped by tier |

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Subnets Module                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌───────────────┐│
│  │   Public Tier   │  │  Private Tier   │  │ Database Tier ││
│  │                 │  │                 │  │               ││
│  │ • AZ-a: 10.0.1  │  │ • AZ-a: 10.0.10 │  │ • AZ-a: 10.0.20││
│  │ • AZ-b: 10.0.2  │  │ • AZ-b: 10.0.11 │  │ • AZ-b: 10.0.21││
│  │                 │  │                 │  │               ││
│  │ • Auto-assign   │  │ • No auto-assign│  │ • No auto-assign││
│  │   public IPs    │  │   public IPs    │  │   public IPs   ││
│  └─────────────────┘  └─────────────────┘  └───────────────┘│
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Security Features

- **Tier-based Organization**: Subnets are organized by tier for better security management
- **Public IP Control**: Configurable auto-assignment of public IPs
- **Tagging**: Comprehensive resource tagging for cost tracking and management
- **Validation**: Input validation to prevent misconfigurations

## Important Notes

1. **CIDR Planning**: Ensure your subnet CIDRs don't overlap and fit within your VPC CIDR.

2. **Availability Zones**: Use different availability zones for high availability.

3. **Tier Organization**: Use consistent tier names (Public, Private, Database) for better organization.

4. **Public IP Assignment**: Only enable `map_public_ip_on_launch` for public subnets.

## Related Modules

- **vpc**: The VPC that contains these subnets
- **routes**: For creating route tables and routes for these subnets
- **security_groups**: For network security rules

## Examples

See the `environments/staging/subnets.tf` file for a complete example of how to use this module in a staging environment.
