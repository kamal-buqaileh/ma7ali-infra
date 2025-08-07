# Routes Module

This module creates route tables and routes within a VPC. It supports multiple route tables with different routing configurations and can associate subnets with route tables.

## Features

- ✅ **Multiple Route Tables**: Support for multiple route tables with different configurations
- ✅ **Flexible Routing**: Configurable routes with gateway and NAT gateway support
- ✅ **Subnet Association**: Automatic association of subnets with route tables
- ✅ **Tagging**: Comprehensive tagging support for resource management
- ✅ **Validation**: Input validation for naming conventions

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

## Usage

### Basic Routes

```hcl
module "routes" {
  source = "../../modules/routes"

  name   = "my-project-staging"
  vpc_id = module.vpc.vpc_id

  route_tables = [
    {
      name = "public"
      routes = [
        {
          cidr_block = "0.0.0.0/0"
          gateway_id = module.vpc.internet_gateway_id
        }
      ]
      subnet_ids = ["subnet-12345678", "subnet-87654321"]
      tags = {
        Purpose = "Public route table"
      }
    },
    {
      name = "private"
      routes = [
        {
          cidr_block     = "0.0.0.0/0"
          nat_gateway_id = "nat-12345678"
        }
      ]
      subnet_ids = ["subnet-11111111", "subnet-22222222"]
      tags = {
        Purpose = "Private route table"
      }
    }
  ]

  tags = {
    Environment = "staging"
    Project     = "my-project"
  }
}
```

### Advanced Routes with Multiple Routes

```hcl
module "routes" {
  source = "../../modules/routes"

  name   = "my-project-production"
  vpc_id = module.vpc.vpc_id

  route_tables = [
    {
      name = "public"
      routes = [
        {
          cidr_block = "0.0.0.0/0"
          gateway_id = module.vpc.internet_gateway_id
        }
      ]
      subnet_ids = module.subnets.subnets_by_tier["Public"]
      tags = {
        Purpose = "Public route table"
      }
    },
    {
      name = "private"
      routes = [
        {
          cidr_block     = "0.0.0.0/0"
          nat_gateway_id = module.nat_gateway.nat_gateway_ids[0]
        },
        {
          cidr_block     = "10.0.0.0/8"
          nat_gateway_id = module.nat_gateway.nat_gateway_ids[1]
        }
      ]
      subnet_ids = concat(
        module.subnets.subnets_by_tier["Private"],
        module.subnets.subnets_by_tier["Database"]
      )
      tags = {
        Purpose = "Private route table"
      }
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
| name | Name prefix for the route tables | `string` | n/a | yes |
| vpc_id | The ID of the VPC | `string` | n/a | yes |
| route_tables | List of route table configurations | `list(object)` | n/a | yes |
| tags | Tags to apply to all route tables | `map(string)` | `{}` | no |

### Route Table Configuration Object

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| name | Name of the route table | `string` | yes |
| routes | List of route configurations | `list(object)` | yes |
| subnet_ids | List of subnet IDs to associate | `list(string)` | yes |
| tags | Tags specific to this route table | `map(string)` | no |

### Route Configuration Object

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| cidr_block | CIDR block for the route | `string` | yes |
| gateway_id | ID of the Internet Gateway (for public routes) | `string` | no |
| nat_gateway_id | ID of the NAT Gateway (for private routes) | `string` | no |

## Outputs

| Name | Description |
|------|-------------|
| route_table_ids | List of route table IDs |
| route_table_arns | List of route table ARNs |
| route_tables_by_name | Map of route table IDs by name |

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Routes Module                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌───────────────┐│
│  │  Public Routes  │  │ Private Routes  │  │ Database Routes││
│  │                 │  │                 │  │               ││
│  │ • 0.0.0.0/0 →   │  │ • 0.0.0.0/0 →   │  │ • 0.0.0.0/0 → ││
│  │   Internet      │  │   NAT Gateway   │  │   NAT Gateway ││
│  │   Gateway       │  │                 │  │               ││
│  │                 │  │ • Subnets:      │  │ • Subnets:    ││
│  │ • Subnets:      │  │   Private       │  │   Database    ││
│  │   Public        │  │                 │  │               ││
│  └─────────────────┘  └─────────────────┘  └───────────────┘│
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Security Features

- **Route Isolation**: Separate route tables for different tiers
- **Gateway Control**: Controlled access to internet and NAT gateways
- **Tagging**: Comprehensive resource tagging for cost tracking and management
- **Validation**: Input validation to prevent misconfigurations

## Important Notes

1. **Route Priority**: Routes are evaluated in order, with the most specific route taking precedence.

2. **Gateway Requirements**: Public routes typically use Internet Gateways, while private routes use NAT Gateways.

3. **Subnet Association**: Each subnet can only be associated with one route table at a time.

4. **CIDR Planning**: Ensure your route CIDRs are appropriate for your network design.

## Related Modules

- **vpc**: The VPC that contains these route tables
- **subnets**: The subnets to be associated with route tables
- **nat_gateway**: For creating NAT gateways for private routes

## Examples

See the `environments/staging/routes.tf` file for a complete example of how to use this module in a staging environment.
