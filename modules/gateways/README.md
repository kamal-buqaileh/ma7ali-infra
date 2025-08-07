# Gateways Module

This module creates and manages various types of gateways for your VPC, including Internet Gateways, NAT Gateways, and VPC Endpoints. It's designed to be flexible and cost-effective, allowing you to create only the gateways you need.

## Features

- ✅ **Internet Gateway**: Optional Internet Gateway for public internet access
- ✅ **NAT Gateways**: Optional NAT Gateways for private subnet internet access
- ✅ **VPC Endpoints**: Optional VPC endpoints for AWS services
- ✅ **Cost Optimization**: Only creates resources when needed
- ✅ **Multi-AZ Support**: NAT gateways can be created across multiple AZs
- ✅ **Tagging**: Comprehensive tagging support for resource management
- ✅ **Validation**: Input validation for naming conventions

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

## Usage

### Basic Internet Gateway Only

```hcl
module "gateways" {
  source = "../../modules/gateways"

  name  = "my-project-staging"
  vpc_id = module.vpc.vpc_id

  create_internet_gateway = true
  create_nat_gateways     = false

  tags = {
    Environment = "staging"
    Project     = "my-project"
  }
}
```

### Internet Gateway + NAT Gateways

```hcl
module "gateways" {
  source = "../../modules/gateways"

  name  = "my-project-staging"
  vpc_id = module.vpc.vpc_id

  create_internet_gateway = true
  create_nat_gateways     = true
  nat_gateway_subnet_ids  = module.subnets.subnets_by_tier["Public"]

  tags = {
    Environment = "staging"
    Project     = "my-project"
  }
}
```

### Full Gateway Setup with VPC Endpoints

```hcl
module "gateways" {
  source = "../../modules/gateways"

  name  = "my-project-production"
  vpc_id = module.vpc.vpc_id

  create_internet_gateway = true
  create_nat_gateways     = true
  nat_gateway_subnet_ids  = module.subnets.subnets_by_tier["Public"]

  vpc_endpoints = {
    s3 = {
      service_name        = "com.amazonaws.us-west-2.s3"
      endpoint_type       = "Gateway"
      subnet_ids          = []
      security_group_ids  = []
      private_dns_enabled = true
      tags = {
        Purpose = "S3 access"
      }
    }
    ecr = {
      service_name        = "com.amazonaws.us-west-2.ecr.dkr"
      endpoint_type       = "Interface"
      subnet_ids          = module.subnets.subnets_by_tier["Private"]
      security_group_ids  = [aws_security_group.vpc_endpoints.id]
      private_dns_enabled = true
      tags = {
        Purpose = "ECR access"
      }
    }
  }

  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name prefix for the gateways | `string` | n/a | yes |
| vpc_id | The ID of the VPC | `string` | n/a | yes |
| create_internet_gateway | Whether to create an Internet Gateway | `bool` | `true` | no |
| create_nat_gateways | Whether to create NAT Gateways | `bool` | `false` | no |
| nat_gateway_subnet_ids | List of subnet IDs where NAT Gateways should be created | `list(string)` | `[]` | no |
| vpc_endpoints | Map of VPC endpoints to create | `map(object)` | `{}` | no |
| tags | Tags to apply to all gateways | `map(string)` | `{}` | no |

### VPC Endpoint Configuration Object

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| service_name | AWS service name for the endpoint | `string` | yes |
| endpoint_type | Type of endpoint (Gateway/Interface) | `string` | yes |
| subnet_ids | List of subnet IDs for Interface endpoints | `list(string)` | no |
| security_group_ids | List of security group IDs for Interface endpoints | `list(string)` | no |
| private_dns_enabled | Whether to enable private DNS | `bool` | no |
| tags | Tags specific to this endpoint | `map(string)` | no |

## Outputs

| Name | Description |
|------|-------------|
| internet_gateway_id | The ID of the Internet Gateway |
| internet_gateway_arn | The ARN of the Internet Gateway |
| nat_gateway_ids | List of NAT Gateway IDs |
| nat_gateway_arns | List of NAT Gateway ARNs |
| nat_gateway_public_ips | List of NAT Gateway public IPs |
| vpc_endpoint_ids | Map of VPC endpoint IDs |
| vpc_endpoint_arns | Map of VPC endpoint ARNs |

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Gateways Module                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌───────────────┐│
│  │ Internet Gateway│  │   NAT Gateways  │  │ VPC Endpoints ││
│  │                 │  │                 │  │               ││
│  │ • Public Access │  │ • Private Access│  │ • S3          ││
│  │ • Optional      │  │ • Multi-AZ      │  │ • ECR         ││
│  │ • Cost: $0      │  │ • Cost: $0.045/h│  │ • EKS         ││
│  │                 │  │                 │  │ • etc.        ││
│  └─────────────────┘  └─────────────────┘  └───────────────┘│
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Cost Considerations

### Internet Gateway
- **Cost**: $0 (free)
- **Use Case**: Public internet access for public subnets

### NAT Gateway
- **Cost**: $0.045/hour + data processing fees
- **Use Case**: Private subnet internet access
- **Recommendation**: Only create when needed for private subnets

### VPC Endpoints
- **Gateway Endpoints**: $0 (free)
- **Interface Endpoints**: $0.01/hour + data processing
- **Use Case**: Private access to AWS services

## Security Features

- **Conditional Creation**: Only creates resources when needed
- **Multi-AZ Support**: NAT gateways can be created across multiple AZs
- **Private DNS**: VPC endpoints can use private DNS for seamless access
- **Security Groups**: Interface endpoints support security groups
- **Tagging**: Comprehensive resource tagging for cost tracking and management

## Important Notes

1. **NAT Gateway Costs**: NAT gateways are expensive ($0.045/hour). Only create them when private subnets need internet access.

2. **VPC Endpoints**: Consider using VPC endpoints for AWS services to reduce NAT gateway costs and improve security.

3. **Multi-AZ**: For production environments, create NAT gateways in multiple AZs for high availability.

4. **Dependencies**: NAT gateways depend on Internet Gateway, so ensure Internet Gateway is created first.

## Related Modules

- **vpc**: The VPC that contains these gateways
- **subnets**: The subnets for NAT gateways and VPC endpoints
- **routes**: For creating routes that use these gateways
- **security_groups**: For VPC endpoint security groups

## Examples

See the `environments/staging/gateways.tf` file for a complete example of how to use this module in a staging environment. 