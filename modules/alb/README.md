# Application Load Balancer (ALB) Module

This module creates an AWS Application Load Balancer with HTTPS termination and configurable target groups for different services.

## Features

- **HTTPS Termination**: Automatically handles SSL/TLS with provided certificate
- **HTTP to HTTPS Redirect**: All HTTP traffic is redirected to HTTPS
- **Multiple Target Groups**: Support for multiple services with host-based routing
- **Security Groups**: Automatically creates security groups with proper rules
- **Health Checks**: Configurable health checks for all target groups
- **High Availability**: Requires minimum 2 subnets across different AZs

## Usage

```hcl
module "alb" {
  source = "../../modules/alb"

  name       = "my-app-alb"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.subnets.public_subnet_ids

  certificate_arn = module.ssl_certificate.certificate_arn
  ssl_policy      = "ELBSecurityPolicy-FS-1-2-Res-2020-10"

  target_groups = {
    web = {
      port         = 3000
      protocol     = "HTTP"
      priority     = 100
      host_headers = ["app.example.com"]
    }
    api = {
      port         = 8000
      protocol     = "HTTP"
      priority     = 200
      host_headers = ["api.example.com"]
      health_check_path = "/api/health"
    }
  }

  tags = {
    Environment = "staging"
    Project     = "my-app"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the Application Load Balancer | `string` | n/a | yes |
| vpc_id | ID of the VPC where the ALB will be created | `string` | n/a | yes |
| subnet_ids | List of subnet IDs (minimum 2) | `list(string)` | n/a | yes |
| certificate_arn | ARN of the SSL certificate | `string` | n/a | yes |
| internal | Whether the load balancer is internal | `bool` | `false` | no |
| ssl_policy | SSL policy for HTTPS listener | `string` | `ELBSecurityPolicy-TLS-1-2-2017-01` | no |
| health_check_path | Health check path for default target group | `string` | `/health` | no |
| target_groups | Map of additional target groups | `map(object)` | `{}` | no |
| enable_deletion_protection | Enable deletion protection | `bool` | `false` | no |
| access_logs_enabled | Enable access logs | `bool` | `false` | no |
| tags | Tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| alb_arn | The ARN of the Application Load Balancer |
| alb_dns_name | The DNS name of the Application Load Balancer |
| alb_zone_id | The zone ID of the Application Load Balancer |
| alb_security_group_id | The security group ID of the ALB |
| default_target_group_arn | The ARN of the default target group |
| target_group_arns | Map of target group ARNs |
| http_listener_arn | The ARN of the HTTP listener |
| https_listener_arn | The ARN of the HTTPS listener |

## Target Group Configuration

Each target group in the `target_groups` map supports:

- `port`: Port number for the target group
- `protocol`: Protocol (HTTP/HTTPS)
- `priority`: Listener rule priority (lower = higher priority)
- `host_headers`: List of host headers for routing
- `health_check_path`: Custom health check path (default: `/health`)
- `health_check_port`: Custom health check port (default: traffic-port)
- `health_check_protocol`: Health check protocol (default: same as target)
- `healthy_threshold`: Number of consecutive successful health checks (default: 2)
- `unhealthy_threshold`: Number of consecutive failed health checks (default: 2)
- `timeout`: Health check timeout in seconds (default: 5)
- `interval`: Health check interval in seconds (default: 30)
- `matcher`: Expected HTTP status codes (default: "200")

## Security

- All HTTP traffic is automatically redirected to HTTPS
- Security groups are configured to allow only HTTP (80) and HTTPS (443) inbound
- Modern SSL policies are supported
- Health checks ensure only healthy targets receive traffic

## High Availability

- Requires deployment across at least 2 availability zones
- Health checks with automatic target removal/addition
- Target health evaluation for Route53 alias records
