# ACM (AWS Certificate Manager) Module

This module creates and validates SSL/TLS certificates using AWS Certificate Manager with automatic DNS validation via Route 53.

## Features

- ✅ **SSL Certificate Creation**: Request SSL/TLS certificates for domains
- ✅ **DNS Validation**: Automatic validation using Route 53 DNS records
- ✅ **Subject Alternative Names**: Support for multiple domains in one certificate
- ✅ **Multiple Key Algorithms**: Support for RSA and EC key algorithms
- ✅ **Certificate Transparency**: Configurable certificate transparency logging
- ✅ **Automatic Renewal**: Certificates auto-renew before expiration
- ✅ **Validation**: Input validation for domain names and configurations

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

## Usage

### Basic SSL Certificate

```hcl
module "ssl_certificate" {
  source = "../../modules/acm"

  domain_name    = "example.com"
  hosted_zone_id = module.route53.hosted_zone_id

  tags = {
    Environment = "staging"
    Project     = "my-project"
  }
}
```

### Wildcard Certificate with SANs

```hcl
module "ssl_certificate" {
  source = "../../modules/acm"

  domain_name = "*.example.com"
  subject_alternative_names = [
    "example.com",
    "api.example.com",
    "admin.example.com"
  ]
  
  hosted_zone_id = module.route53.hosted_zone_id
  key_algorithm  = "RSA_2048"

  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}
```

### Certificate with EC Key Algorithm

```hcl
module "ssl_certificate" {
  source = "../../modules/acm"

  domain_name    = "example.com"
  hosted_zone_id = module.route53.hosted_zone_id
  key_algorithm  = "EC_prime256v1"
  
  certificate_transparency_logging_preference = "ENABLED"

  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| domain_name | The domain name for the certificate | `string` | n/a | yes |
| subject_alternative_names | Additional domain names for the certificate (SANs) | `list(string)` | `[]` | no |
| hosted_zone_id | The Route53 hosted zone ID for DNS validation | `string` | n/a | yes |
| validation_method | Method to use for certificate validation (DNS or EMAIL) | `string` | `"DNS"` | no |
| key_algorithm | The algorithm for the certificate's private key | `string` | `"RSA_2048"` | no |
| certificate_transparency_logging_preference | Certificate transparency logging preference | `string` | `"ENABLED"` | no |
| tags | Tags to apply to ACM certificate | `map(string)` | `{}` | no |

### Supported Key Algorithms

| Algorithm | Description | Use Case |
|-----------|-------------|----------|
| `RSA_1024` | RSA 1024-bit | Legacy (not recommended) |
| `RSA_2048` | RSA 2048-bit | Standard (recommended) |
| `RSA_3072` | RSA 3072-bit | High security |
| `RSA_4096` | RSA 4096-bit | Maximum security |
| `EC_prime256v1` | ECDSA P-256 | Modern, efficient |
| `EC_secp384r1` | ECDSA P-384 | High security EC |
| `EC_secp521r1` | ECDSA P-521 | Maximum security EC |

## Outputs

| Name | Description |
|------|-------------|
| certificate_arn | The ARN of the certificate |
| certificate_domain_name | The domain name of the certificate |
| certificate_status | The status of the certificate |
| certificate_subject_alternative_names | The subject alternative names of the certificate |
| validation_record_fqdns | The FQDNs of the validation records |

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        ACM Module                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌───────────────┐│
│  │  SSL Certificate│  │  DNS Validation │  │  Route 53     ││
│  │                 │  │                 │  │               ││
│  │ • Domain        │  │ • Auto-created  │  │ • Validation  ││
│  │ • SANs          │  │ • CNAME records │  │   Records     ││
│  │ • Key Algorithm │  │ • Auto-validated│  │ • DNS Zone    ││
│  │ • Auto-renewal  │  │ • 5min timeout  │  │               ││
│  └─────────────────┘  └─────────────────┘  └───────────────┘│
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Security Features

### Automatic Security Measures

- **DNS Validation**: More secure than email validation
- **Certificate Transparency**: Logs certificates for security monitoring
- **Auto-renewal**: Prevents certificate expiration
- **Strong Algorithms**: Support for modern cryptographic algorithms

### Best Practices

- **Use RSA_2048 or EC_prime256v1** for most applications
- **Enable certificate transparency** for security monitoring
- **Use wildcard certificates** for multiple subdomains
- **Include root domain** in SANs when using wildcard

## Important Notes

1. **DNS Validation**: Requires Route 53 hosted zone for the domain.

2. **Validation Time**: Certificate validation typically takes 5-10 minutes.

3. **Regional Certificates**: For CloudFront, certificates must be in us-east-1.

4. **Wildcard Limitations**: Wildcard certificates don't cover the root domain automatically.

5. **Certificate Limits**: AWS has limits on certificates per account and domain.

## Cost Information

- **Certificate Cost**: FREE for AWS-issued certificates
- **DNS Validation**: Small Route 53 query costs
- **No Renewal Fees**: Automatic renewal is free

## Examples

### Complete Website Certificate

```hcl
module "website_certificate" {
  source = "../../modules/acm"

  domain_name = "*.mywebsite.com"
  subject_alternative_names = [
    "mywebsite.com",
    "api.mywebsite.com",
    "admin.mywebsite.com"
  ]
  
  hosted_zone_id = module.route53.hosted_zone_id
  key_algorithm  = "RSA_2048"

  tags = {
    Environment = "production"
    Project     = "my-website"
    Purpose     = "Website SSL"
  }
}
```

### API-Only Certificate

```hcl
module "api_certificate" {
  source = "../../modules/acm"

  domain_name    = "api.mywebsite.com"
  hosted_zone_id = module.route53.hosted_zone_id
  key_algorithm  = "EC_prime256v1"  # More efficient for APIs

  tags = {
    Environment = "production"
    Project     = "my-website"
    Purpose     = "API SSL"
  }
}
```

## Related Modules

- **route53**: Required for DNS validation
- **alb**: Uses certificates for HTTPS listeners
- **cloudfront**: Uses certificates for HTTPS distribution
