# Route 53 Module

This module creates and manages AWS Route 53 hosted zones and DNS records for domain management and DNS resolution.

## Features

- ✅ **Hosted Zone Management**: Create new or use existing hosted zones
- ✅ **DNS Records**: Support for A, AAAA, CNAME, MX, TXT, and other record types
- ✅ **Alias Records**: Support for AWS resource aliases (ALB, CloudFront, etc.)
- ✅ **Flexible Configuration**: Create multiple DNS records with different configurations
- ✅ **Validation**: Input validation for domain names and record types
- ✅ **Tagging**: Comprehensive tagging support for resource management

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

## Usage

### Basic Hosted Zone

```hcl
module "route53" {
  source = "../../modules/route53"

  domain_name = "example.com"
  
  tags = {
    Environment = "staging"
    Project     = "my-project"
  }
}
```

### Hosted Zone with DNS Records

```hcl
module "route53" {
  source = "../../modules/route53"

  domain_name = "example.com"

  dns_records = {
    "www.example.com" = {
      type    = "A"
      ttl     = 300
      records = ["1.2.3.4"]
    }
    "mail.example.com" = {
      type    = "MX"
      ttl     = 300
      records = ["10 mail.example.com"]
    }
    "api.example.com" = {
      type = "A"
      alias = {
        name                   = "my-alb-123456789.us-west-2.elb.amazonaws.com"
        zone_id                = "Z1D633PJN98FT9"
        evaluate_target_health = true
      }
    }
  }

  tags = {
    Environment = "staging"
    Project     = "my-project"
  }
}
```

### Using Existing Hosted Zone

```hcl
module "route53" {
  source = "../../modules/route53"

  domain_name        = "example.com"
  create_hosted_zone = false
  hosted_zone_id     = "Z123456789ABCDEF"

  dns_records = {
    "api.example.com" = {
      type    = "A"
      ttl     = 300
      records = ["1.2.3.4"]
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
| domain_name | The domain name for the hosted zone | `string` | n/a | yes |
| create_hosted_zone | Whether to create a new hosted zone or use existing one | `bool` | `true` | no |
| hosted_zone_id | Existing hosted zone ID (required if create_hosted_zone is false) | `string` | `null` | no |
| dns_records | Map of DNS records to create | `map(object)` | `{}` | no |
| tags | Tags to apply to Route53 resources | `map(string)` | `{}` | no |

### DNS Record Configuration Object

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| type | DNS record type (A, AAAA, CNAME, MX, TXT, etc.) | `string` | yes |
| ttl | Time to live in seconds | `number` | no (default: 300) |
| records | List of record values | `list(string)` | no (required for non-alias) |
| alias | Alias configuration for AWS resources | `object` | no |

### Alias Configuration Object

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| name | DNS name of the target resource | `string` | yes |
| zone_id | Hosted zone ID of the target resource | `string` | yes |
| evaluate_target_health | Whether to evaluate target health | `bool` | no (default: false) |

## Outputs

| Name | Description |
|------|-------------|
| hosted_zone_id | The hosted zone ID |
| hosted_zone_arn | The hosted zone ARN |
| name_servers | The name servers for the hosted zone |
| domain_name | The domain name |
| dns_record_fqdns | Map of DNS record FQDNs |

## Examples

### Complete Website Setup

```hcl
module "route53" {
  source = "../../modules/route53"

  domain_name = "mywebsite.com"

  dns_records = {
    # Root domain pointing to ALB
    "mywebsite.com" = {
      type = "A"
      alias = {
        name                   = module.alb.dns_name
        zone_id                = module.alb.zone_id
        evaluate_target_health = true
      }
    }
    
    # WWW subdomain
    "www.mywebsite.com" = {
      type = "A"
      alias = {
        name                   = module.alb.dns_name
        zone_id                = module.alb.zone_id
        evaluate_target_health = true
      }
    }
    
    # API subdomain
    "api.mywebsite.com" = {
      type = "A"
      alias = {
        name                   = module.api_alb.dns_name
        zone_id                = module.api_alb.zone_id
        evaluate_target_health = true
      }
    }
    
    # Email verification
    "_amazonses.mywebsite.com" = {
      type    = "TXT"
      ttl     = 300
      records = ["verification-token-here"]
    }
  }

  tags = {
    Environment = "production"
    Project     = "my-website"
  }
}
```

## Important Notes

1. **Name Servers**: After creating a hosted zone, update your domain registrar with the returned name servers.

2. **DNS Propagation**: DNS changes can take up to 48 hours to propagate globally.

3. **Alias vs CNAME**: Use alias records for AWS resources (ALB, CloudFront) as they're more efficient and work at the root domain.

4. **TTL Values**: Lower TTL values allow faster DNS changes but increase query load.

## Related Modules

- **acm**: For SSL certificates that require DNS validation
- **alb**: For load balancer alias records
- **cloudfront**: For CDN alias records
