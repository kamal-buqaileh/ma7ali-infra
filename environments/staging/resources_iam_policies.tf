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
# RDS RESOURCE POLICIES
# =============================================================================
# Note: For single-account RDS setup, identity-based policies in iam_policies.tf
# provide sufficient access control. Resource-based policies will be added when
# cross-account access or EKS integration is needed.


