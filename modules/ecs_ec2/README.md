# ECS EC2 Module

This module creates EC2 capacity for Amazon ECS clusters using Auto Scaling Groups and ECS Capacity Providers. It provides cost-optimized compute resources that can scale to zero when not needed.

## Features

- ✅ **Auto Scaling Group**: Manages EC2 instances for ECS workloads
- ✅ **ECS Capacity Provider**: Integrates with ECS for automatic scaling
- ✅ **Cost Optimized**: ARM64 instances, scaling to zero, spot instance support
- ✅ **Security**: KMS encryption, security groups, SSM access
- ✅ **Monitoring**: CloudWatch integration, ECS container insights
- ✅ **Flexible Configuration**: Multiple instance types, storage options
- ✅ **ECS Optimized AMI**: Latest Amazon Linux 2 with ECS agent pre-installed

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.0 |

## Usage

### Basic ECS EC2 Capacity

```hcl
module "ecs_ec2" {
  source = "../../modules/ecs_ec2"

  cluster_name           = "my-staging-cluster"
  vpc_id                = module.vpc.vpc_id
  subnet_ids            = module.subnets.private_subnet_ids
  region                = "eu-central-1"
  kms_key_arn          = module.kms.key_arn
  instance_profile_name = aws_iam_instance_profile.ecs.name

  # Instance configuration
  instance_type = "t4g.micro"  # ARM64 for cost savings
  ami_type      = "arm64"
  min_size      = 0            # Scale to zero
  max_size      = 5
  desired_capacity = 1

  # Security
  alb_security_group_ids = [module.alb.security_group_id]

  tags = {
    Environment = "staging"
    Project     = "my-project"
  }
}
```

### Production Configuration

```hcl
module "ecs_ec2" {
  source = "../../modules/ecs_ec2"

  cluster_name           = "my-prod-cluster"
  vpc_id                = module.vpc.vpc_id
  subnet_ids            = module.subnets.private_subnet_ids
  region                = "eu-central-1"
  kms_key_arn          = module.kms.key_arn
  instance_profile_name = aws_iam_instance_profile.ecs.name

  # Production instance configuration
  instance_type = "m5.large"
  ami_type      = "x86_64"
  min_size      = 2            # High availability
  max_size      = 20
  desired_capacity = 3

  # Enhanced security
  key_name = "my-prod-key"
  ssh_allowed_cidr_blocks = ["10.0.0.0/16"]
  
  # Capacity provider tuning
  target_capacity = 90
  protect_from_scale_in = true
  
  # Health checks
  health_check_grace_period = 600

  tags = {
    Environment = "production"
    Project     = "my-project"
    Backup      = "required"
  }
}
```

### Cost-Optimized Staging

```hcl
module "ecs_ec2" {
  source = "../../modules/ecs_ec2"

  cluster_name           = "staging-cluster"
  vpc_id                = module.vpc.vpc_id
  subnet_ids            = module.subnets.private_subnet_ids
  region                = "eu-central-1"
  kms_key_arn          = module.kms.key_arn
  instance_profile_name = aws_iam_instance_profile.ecs.name

  # Maximum cost optimization
  instance_type = "t4g.nano"   # Smallest ARM64 instance
  ami_type      = "arm64"
  min_size      = 0            # Scale to zero
  max_size      = 3            # Limit max instances
  desired_capacity = 0         # Start with zero

  # Storage optimization
  volume_size = 20             # Minimum viable size
  volume_type = "gp3"          # Best price/performance

  # Aggressive scaling
  target_capacity = 60         # Lower target for cost
  protect_from_scale_in = false
  
  # No SSH access (use SSM instead)
  key_name = null

  tags = {
    Environment   = "staging"
    Project       = "my-project"
    CostOptimized = "true"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_name | Name of the ECS cluster | `string` | n/a | yes |
| vpc_id | ID of the VPC | `string` | n/a | yes |
| subnet_ids | List of subnet IDs | `list(string)` | n/a | yes |
| region | AWS region | `string` | n/a | yes |
| kms_key_arn | ARN of the KMS key | `string` | n/a | yes |
| instance_profile_name | IAM instance profile name | `string` | n/a | yes |
| instance_type | EC2 instance type | `string` | `"t4g.micro"` | no |
| ami_type | AMI architecture type | `string` | `"arm64"` | no |
| min_size | Minimum instances | `number` | `0` | no |
| max_size | Maximum instances | `number` | `10` | no |
| desired_capacity | Desired instances | `number` | `1` | no |
| volume_size | EBS volume size in GB | `number` | `30` | no |
| volume_type | EBS volume type | `string` | `"gp3"` | no |
| target_capacity | Target capacity percentage | `number` | `80` | no |
| protect_from_scale_in | Enable scale-in protection | `bool` | `false` | no |
| key_name | EC2 Key Pair name | `string` | `null` | no |
| alb_security_group_ids | ALB security group IDs | `list(string)` | `[]` | no |
| tags | Tags to apply | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| launch_template_id | ID of the launch template |
| autoscaling_group_arn | ARN of the Auto Scaling Group |
| capacity_provider_name | Name of the ECS capacity provider |
| security_group_id | ID of the security group |
| ami_id | AMI ID used for instances |
| cluster_name | ECS cluster name |

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    ECS EC2 Capacity                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────┐    ┌─────────────────┐                │
│  │ Launch Template │    │ Auto Scaling    │                │
│  │                 │    │ Group           │                │
│  │ • ECS AMI       │    │                 │                │
│  │ • Instance Type │    │ • Min/Max Size  │                │
│  │ • User Data     │    │ • Desired Cap   │                │
│  │ • Security Grps │    │ • Health Checks │                │
│  │ • IAM Profile   │    │ • Termination   │                │
│  └─────────────────┘    └─────────────────┘                │
│                                                             │
│  ┌─────────────────┐    ┌─────────────────┐                │
│  │ ECS Capacity    │    │ Security        │                │
│  │ Provider        │    │ Group           │                │
│  │                 │    │                 │                │
│  │ • Managed Scale │    │ • ALB Access    │                │
│  │ • Target Cap    │    │ • SSH (opt)     │                │
│  │ • Scale Steps   │    │ • Outbound      │                │
│  └─────────────────┘    └─────────────────┘                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Cost Optimization Features

### 1. ARM64 Instances
- **t4g family**: 20-40% cheaper than x86 equivalents
- **Better price/performance**: More compute per dollar
- **ECS optimized**: Native ARM64 container support

### 2. Scaling to Zero
- **min_size = 0**: No minimum running instances
- **Automatic scaling**: ECS starts instances when needed
- **Cost savings**: Pay only for running workloads

### 3. GP3 Storage
- **Latest generation**: Better IOPS and throughput
- **Cost effective**: 20% cheaper than GP2
- **Flexible**: Configurable IOPS and throughput

### 4. Spot Instance Ready
- **Spot instance draining**: Graceful task migration
- **ECS integration**: Automatic spot instance handling
- **Up to 90% savings**: Compared to on-demand pricing

## Security Features

- **KMS Encryption**: EBS volumes encrypted at rest
- **Enhanced Security Groups**: Restrictive egress rules with documented exceptions
  - HTTPS (443): External API calls (Stripe, SendGrid, etc.)
  - HTTP (80): Package repositories and updates
  - DNS (53): Domain name resolution
  - NTP (123): Time synchronization
  - VPC Internal: Full TCP communication within VPC CIDR
- **IMDSv2**: Instance Metadata Service v2 enforced for enhanced security
- **SSM Access**: Secure remote access without SSH keys
- **IAM Integration**: Instance profiles with least privilege
- **VPC Integration**: Private subnet deployment only
- **Minimal User Data**: Only essential ECS cluster configuration

## Best Practices

1. **Use ARM64 instances** (t4g family) for better cost efficiency
2. **Enable scaling to zero** for development/staging environments
3. **Set appropriate target capacity** (60-80% for cost optimization)
4. **Use GP3 storage** for better price/performance
5. **Disable scale-in protection** for cost-sensitive workloads
6. **Monitor CloudWatch metrics** for optimization opportunities
7. **Use SSM instead of SSH** for secure remote access

## Integration with ECS

This module creates:
- **ECS Capacity Provider**: Registered with your ECS cluster
- **Auto Scaling Group**: Manages EC2 instance lifecycle
- **Launch Template**: Defines instance configuration
- **Security Groups**: Controls network access

The capacity provider automatically:
- **Scales instances** based on ECS task placement
- **Drains instances** gracefully during termination
- **Manages capacity** according to target utilization

## Examples

- **Development**: t4g.nano, scale to zero, no SSH
- **Staging**: t4g.micro, limited scaling, basic monitoring
- **Production**: m5.large, high availability, enhanced monitoring
- **Batch Processing**: c5.xlarge, scale to zero, compute optimized

## Related Modules

- **ecs**: Main ECS cluster and services
- **vpc**: Network infrastructure
- **alb**: Load balancer integration
- **iam**: IAM roles and policies
