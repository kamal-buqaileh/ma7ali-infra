# ECS Module

This module creates an Amazon ECS (Elastic Container Service) cluster with task definitions and services. It focuses on container orchestration and integrates with the separate `ecs_ec2` module for EC2 capacity management.

## Features

- ✅ **ECS Cluster**: Managed container orchestration service
- ✅ **Task Definitions**: Define container specifications and resource requirements
- ✅ **ECS Services**: Manage desired state and deployments
- ✅ **Multiple Launch Types**: Fargate, Fargate Spot support
- ✅ **CloudWatch Logging**: Centralized logging with KMS encryption
- ✅ **Load Balancer Integration**: ALB target group support
- ✅ **Service Discovery**: AWS Cloud Map integration
- ✅ **Flexible Configuration**: Task definitions and services as code

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

### Basic ECS Cluster

```hcl
module "ecs" {
  source = "../../modules/ecs"

  cluster_name = "my-staging-cluster"
  kms_key_arn  = module.kms.key_arn

  # Cost optimizations for staging
  log_retention_days        = 7
  enable_container_insights = false

  # Capacity providers
  capacity_providers = ["FARGATE_SPOT", "FARGATE"]
  default_capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE_SPOT"
      weight           = 100
    }
  ]

  tags = {
    Environment = "staging"
    Project     = "my-project"
  }
}
```

### ECS with Task Definitions and Services

```hcl
module "ecs" {
  source = "../../modules/ecs"

  cluster_name = "my-app-cluster"
  kms_key_arn  = module.kms.key_arn

  # Task definitions
  task_definitions = {
    frontend = {
      family                   = "frontend"
      network_mode            = "bridge"
      requires_compatibilities = ["EC2", "FARGATE"]
      cpu                     = "256"
      memory                  = "512"
      execution_role_arn      = aws_iam_role.ecs_task_execution_role.arn
      task_role_arn          = aws_iam_role.ecs_task_role.arn
      
      container_definitions = [
        {
          name  = "frontend"
          image = "${module.ecr.repository_urls["frontend"]}:latest"
          memory = 512
          portMappings = [
            {
              containerPort = 3000
              protocol      = "tcp"
            }
          ]
          logConfiguration = {
            logDriver = "awslogs"
            options = {
              "awslogs-group"         = "/aws/ecs/my-app-cluster"
              "awslogs-region"        = "eu-central-1"
              "awslogs-stream-prefix" = "frontend"
            }
          }
        }
      ]
    }

    backend = {
      family                   = "backend"
      network_mode            = "bridge"
      requires_compatibilities = ["EC2", "FARGATE"]
      cpu                     = "512"
      memory                  = "1024"
      execution_role_arn      = aws_iam_role.ecs_task_execution_role.arn
      task_role_arn          = aws_iam_role.ecs_task_role.arn
      
      container_definitions = [
        {
          name  = "backend"
          image = "${module.ecr.repository_urls["backend"]}:latest"
          memory = 1024
          portMappings = [
            {
              containerPort = 8000
              protocol      = "tcp"
            }
          ]
          secrets = [
            {
              name      = "DATABASE_URL"
              valueFrom = module.rds.db_password_secret_arn
            }
          ]
          logConfiguration = {
            logDriver = "awslogs"
            options = {
              "awslogs-group"         = "/aws/ecs/my-app-cluster"
              "awslogs-region"        = "eu-central-1"
              "awslogs-stream-prefix" = "backend"
            }
          }
        }
      ]
    }
  }

  # Services
  services = {
    frontend = {
      name                = "frontend"
      task_definition_key = "frontend"
      desired_count       = 2
      launch_type         = "EC2"
      
      load_balancers = [
        {
          target_group_arn = module.alb.target_group_arns["frontend"]
          container_name   = "frontend"
          container_port   = 3000
        }
      ]
    }

    backend = {
      name                = "backend"
      task_definition_key = "backend"
      desired_count       = 2
      launch_type         = "FARGATE_SPOT"
      
      network_configuration = {
        subnets         = module.subnets.private_subnet_ids
        security_groups = [aws_security_group.ecs_tasks.id]
      }
      
      load_balancers = [
        {
          target_group_arn = module.alb.target_group_arns["backend"]
          container_name   = "backend"
          container_port   = 8000
        }
      ]
    }
  }

  tags = {
    Environment = "staging"
    Project     = "my-project"
  }
}
```

### Integration with ECS EC2 Module

```hcl
# ECS Cluster
module "ecs" {
  source = "../../modules/ecs"

  cluster_name = "my-cluster"
  kms_key_arn  = module.kms.key_arn

  # Include EC2 capacity provider from ecs_ec2 module
  capacity_providers = ["FARGATE_SPOT", "FARGATE", "my-cluster-ec2"]

  task_definitions = local.task_definitions
  services         = local.services

  tags = var.tags
}

# EC2 Capacity
module "ecs_ec2" {
  source = "../../modules/ecs_ec2"

  cluster_name           = "my-cluster"
  vpc_id                = module.vpc.vpc_id
  subnet_ids            = module.subnets.private_subnet_ids
  region                = "eu-central-1"
  kms_key_arn          = module.kms.key_arn
  instance_profile_name = aws_iam_instance_profile.ecs.name

  # This creates the "my-cluster-ec2" capacity provider
  instance_type = "t4g.micro"
  min_size      = 0
  max_size      = 5

  tags = var.tags
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_name | Name of the ECS cluster | `string` | n/a | yes |
| kms_key_arn | ARN of the KMS key | `string` | n/a | yes |
| log_retention_days | CloudWatch log retention days | `number` | `14` | no |
| enable_container_insights | Enable Container Insights | `bool` | `true` | no |
| capacity_providers | List of capacity providers | `list(string)` | `["FARGATE", "FARGATE_SPOT"]` | no |
| default_capacity_provider_strategy | Default capacity provider strategy | `list(object)` | See variables.tf | no |
| task_definitions | Map of task definitions | `map(object)` | `{}` | no |
| services | Map of ECS services | `map(object)` | `{}` | no |
| tags | Tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | The ID of the ECS cluster |
| cluster_name | The name of the ECS cluster |
| cluster_arn | The ARN of the cluster |
| cloudwatch_log_group_name | Name of the CloudWatch log group |
| task_definition_arns | Map of task definition ARNs |
| service_names | Map of ECS service names |
| service_arns | Map of ECS service ARNs |

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     ECS Cluster                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────┐    ┌─────────────────┐                │
│  │ Capacity        │    │ Task            │                │
│  │ Providers       │    │ Definitions     │                │
│  │                 │    │                 │                │
│  │ • Fargate       │    │ • Frontend      │                │
│  │ • Fargate Spot  │    │ • Backend       │                │
│  │ • EC2 (ext)     │    │ • Admin         │                │
│  └─────────────────┘    └─────────────────┘                │
│                                                             │
│  ┌─────────────────┐    ┌─────────────────┐                │
│  │ CloudWatch      │    │ ECS Services    │                │
│  │ Logs            │    │                 │                │
│  │                 │    │ • Load Balanced │                │
│  │ • KMS Encrypted │    │ • Health Checks │                │
│  │ • Configurable  │    │ • Auto Scaling  │                │
│  │ • Retention     │    │ • Rolling Deploy│                │
│  └─────────────────┘    └─────────────────┘                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Module Separation

This module is part of a two-module architecture:

### **ECS Module** (this module)
- **Focus**: Container orchestration
- **Resources**: Cluster, task definitions, services
- **Responsibilities**: Application deployment and management

### **ECS EC2 Module** (separate)
- **Focus**: Compute capacity
- **Resources**: Auto Scaling Groups, Launch Templates, Capacity Providers
- **Responsibilities**: Instance management and scaling

### **Benefits of Separation**
1. **Single Responsibility**: Each module has a clear focus
2. **Reusability**: Use ECS module with different capacity types
3. **Flexibility**: Mix Fargate and EC2 capacity as needed
4. **Maintainability**: Easier to update and test individual components

## Cost Optimization Features

### 1. Fargate Spot Priority
- Use `FARGATE_SPOT` as primary capacity provider
- Up to 70% savings compared to regular Fargate
- Automatic spot instance handling

### 2. Configurable Logging
- Adjustable log retention periods
- Optional Container Insights (disable for staging)
- KMS encryption for security

### 3. Flexible Capacity
- Support for multiple capacity providers
- Easy integration with cost-optimized EC2 capacity
- Dynamic scaling based on demand

## Security Features

- **KMS Encryption**: Logs encrypted at rest
- **IAM Integration**: Task roles and execution roles
- **Network Security**: VPC integration, security groups
- **Container Security**: Image scanning via ECR
- **Access Control**: Fine-grained permissions

## Best Practices

1. **Use Fargate Spot** for cost-sensitive workloads
2. **Set appropriate log retention** (7 days for staging, 30+ for production)
3. **Use task roles** for least-privilege access
4. **Enable Container Insights** for production monitoring
5. **Implement health checks** for all services
6. **Use blue/green deployments** for zero-downtime updates
7. **Separate task definitions** into dedicated files for maintainability

## Examples

- **Web Application**: Frontend + Backend services
- **Microservices**: Multiple services with service discovery
- **Batch Processing**: Scheduled tasks with Fargate
- **Development**: Cost-optimized staging environment

## Related Modules

- **ecs_ec2**: EC2 capacity for ECS clusters
- **vpc**: VPC and networking infrastructure
- **alb**: Application Load Balancer integration
- **ecr**: Container image registry
- **rds**: Database connectivity