# Resource-based policies for staging environment
# This file contains policies that are attached directly to AWS resources
# These control WHO can access the resources, not what resources users can access

# Data sources for resource references
data "aws_caller_identity" "resources" {}
data "aws_region" "resources" {}

# =============================================================================
# VPC ENDPOINT RESOURCE POLICIES
# =============================================================================

# VPC Endpoint policy that gets attached to the VPC endpoints themselves
# This controls which principals can use the VPC endpoints
locals {
  vpc_endpoint_policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.resources.account_id}:root"
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:DescribeRepositories",
          "ecr:DescribeImages",
          "ecr:ListImages",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:PrincipalAccount" = data.aws_caller_identity.resources.account_id
          }
        }
      }
    ]
  }
}

# =============================================================================
# ECS SERVICE ROLES
# =============================================================================
# These are resource-based IAM roles that AWS services assume to perform actions
# on behalf of your ECS cluster and tasks

# ECS Task Execution Role - Used by ECS service to pull images and publish logs
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project_name}-${var.environment}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "ECS task execution role"
    Service     = "ECS"
    ManagedBy   = "Terraform"
  }
}

# Attach AWS managed policy for ECS task execution
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_task_execution_role.name
}

# Custom policy for ECS task execution role (ECR and Secrets Manager access)
resource "aws_iam_role_policy" "ecs_task_execution_custom_policy" {
  name = "${var.project_name}-${var.environment}-ecs-task-execution-custom-policy"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          module.ssm.secret_arns["database_credentials"],
          "arn:aws:secretsmanager:${data.aws_region.resources.name}:${data.aws_caller_identity.resources.account_id}:secret:${var.project_name}-${var.environment}-*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = [
          module.main_kms_key.arn
        ]
        Condition = {
          StringEquals = {
            "kms:ViaService" = [
              "secretsmanager.${data.aws_region.resources.name}.amazonaws.com",
              "logs.${data.aws_region.resources.name}.amazonaws.com"
            ]
          }
        }
      }
    ]
  })
}

# ECS Task Role - Used by the application running in containers
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.project_name}-${var.environment}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "ECS task role for application permissions"
    Service     = "ECS"
    ManagedBy   = "Terraform"
  }
}

# Custom policy for ECS task role (application-specific permissions)
resource "aws_iam_role_policy" "ecs_task_role_policy" {
  name = "${var.project_name}-${var.environment}-ecs-task-role-policy"
  role = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "${module.s3.bucket_arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          module.s3.bucket_arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          module.ssm.secret_arns["database_credentials"]
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = [
          module.main_kms_key.arn
        ]
        Condition = {
          StringEquals = {
            "kms:ViaService" = [
              "secretsmanager.${data.aws_region.resources.name}.amazonaws.com",
              "s3.${data.aws_region.resources.name}.amazonaws.com"
            ]
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "arn:aws:logs:${data.aws_region.resources.name}:${data.aws_caller_identity.resources.account_id}:log-group:/aws/ecs/${var.project_name}-${var.environment}-*"
        ]
      }
    ]
  })
}

# ECS Instance Role - Used by EC2 instances in the ECS cluster
resource "aws_iam_role" "ecs_instance_role" {
  name = "${var.project_name}-${var.environment}-ecs-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "ECS EC2 instance role"
    Service     = "ECS"
    ManagedBy   = "Terraform"
  }
}

# Attach AWS managed policy for ECS instances
resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  role       = aws_iam_role.ecs_instance_role.name
}

# Attach SSM managed instance core policy for remote access
resource "aws_iam_role_policy_attachment" "ecs_instance_ssm_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.ecs_instance_role.name
}

# Custom policy for ECS instance role
resource "aws_iam_role_policy" "ecs_instance_custom_policy" {
  name = "${var.project_name}-${var.environment}-ecs-instance-custom-policy"
  role = aws_iam_role.ecs_instance_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = [
          "arn:aws:logs:${data.aws_region.resources.name}:${data.aws_caller_identity.resources.account_id}:log-group:/aws/ecs/${var.project_name}-${var.environment}-*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:CreateCluster",
          "ecs:DeregisterContainerInstance",
          "ecs:DiscoverPollEndpoint",
          "ecs:Poll",
          "ecs:RegisterContainerInstance",
          "ecs:StartTelemetrySession",
          "ecs:UpdateContainerInstancesState",
          "ecs:Submit*"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = [
          module.main_kms_key.arn
        ]
        Condition = {
          StringEquals = {
            "kms:ViaService" = [
              "logs.${data.aws_region.resources.name}.amazonaws.com"
            ]
          }
        }
      }
    ]
  })
}


