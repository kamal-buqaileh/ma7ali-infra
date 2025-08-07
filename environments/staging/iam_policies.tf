# Data sources for specific resources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

module "s3_admin_policy" {
  source      = "../../modules/iam_policies"
  name        = "s3-admin-policy"
  description = "Full access to S3"
  path        = "/"

  policy_document = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:GetBucketVersioning",
          "s3:GetBucketEncryption",
          "s3:PutBucketVersioning",
          "s3:PutBucketEncryption",
          "s3:PutBucketLogging",
          "s3:GetBucketLogging",
          "s3:PutBucketPolicy",
          "s3:GetBucketPolicy",
          "s3:DeleteBucketPolicy"
        ]
        Resource = [module.s3.bucket_arn]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = ["${module.s3.bucket_arn}/*"]
      }
    ]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-s3-admin-policy"
    Environment = var.environment
    Purpose     = "S3 administration"
    Service     = "S3"
  }
}

module "s3_developer_policy" {
  source      = "../../modules/iam_policies"
  name        = "s3-developer-policy"
  description = "Read/Write access to S3 (no delete)"
  path        = "/"

  policy_document = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [module.s3.bucket_arn]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = ["${module.s3.bucket_arn}/*"]
      }
    ]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-s3-developer-policy"
    Environment = var.environment
    Purpose     = "S3 development"
    Service     = "S3"
  }
}

module "s3_viewer_policy" {
  source      = "../../modules/iam_policies"
  name        = "s3-viewer-policy"
  description = "Read-only access to S3"
  path        = "/"

  policy_document = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [module.s3.bucket_arn]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = ["${module.s3.bucket_arn}/*"]
      }
    ]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-s3-viewer-policy"
    Environment = var.environment
    Purpose     = "S3 viewing"
    Service     = "S3"
  }
}

# VPC Policies (using EC2 actions - this is correct!)
module "vpc_admin_policy" {
  source      = "../../modules/iam_policies"
  name        = "vpc-admin-policy"
  description = "Full access to VPC resources (EC2 service)"
  path        = "/"

  policy_document = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateVpc",
          "ec2:DeleteVpc",
          "ec2:DescribeVpcs",
          "ec2:ModifyVpcAttribute",
          "ec2:CreateSubnet",
          "ec2:DeleteSubnet",
          "ec2:DescribeSubnets",
          "ec2:ModifySubnetAttribute",
          "ec2:CreateRouteTable",
          "ec2:DeleteRouteTable",
          "ec2:DescribeRouteTables",
          "ec2:CreateRoute",
          "ec2:DeleteRoute",
          "ec2:CreateInternetGateway",
          "ec2:DeleteInternetGateway",
          "ec2:DescribeInternetGateways",
          "ec2:AttachInternetGateway",
          "ec2:DetachInternetGateway",
          "ec2:CreateNatGateway",
          "ec2:DeleteNatGateway",
          "ec2:DescribeNatGateways",
          "ec2:AllocateAddress",
          "ec2:ReleaseAddress",
          "ec2:DescribeAddresses",
          "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup",
          "ec2:DescribeSecurityGroups",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:CreateFlowLogs",
          "ec2:DeleteFlowLogs",
          "ec2:DescribeFlowLogs"
        ]
        Resource = "*"
      }
    ]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc-admin-policy"
    Environment = var.environment
    Purpose     = "VPC administration"
    Service     = "VPC"
  }
}

module "vpc_developer_policy" {
  source      = "../../modules/iam_policies"
  name        = "vpc-developer-policy"
  description = "Developer access to VPC resources (no delete)"
  path        = "/"

  policy_document = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeRouteTables",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeNatGateways",
          "ec2:DescribeAddresses",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeFlowLogs"
        ]
        Resource = "*"
      }
    ]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc-developer-policy"
    Environment = var.environment
    Purpose     = "VPC development"
    Service     = "VPC"
  }
}

module "vpc_viewer_policy" {
  source      = "../../modules/iam_policies"
  name        = "vpc-viewer-policy"
  description = "Read-only access to VPC resources"
  path        = "/"

  policy_document = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeRouteTables",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeNatGateways",
          "ec2:DescribeAddresses",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeFlowLogs"
        ]
        Resource = "*"
      }
    ]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc-viewer-policy"
    Environment = var.environment
    Purpose     = "VPC viewing"
    Service     = "VPC"
  }
}

# CloudWatch Policies (removed duplicate flow log permissions)
module "cloudwatch_admin_policy" {
  source      = "../../modules/iam_policies"
  name        = "cloudwatch-admin-policy"
  description = "Full access to CloudWatch resources"
  path        = "/"

  policy_document = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:DeleteLogGroup",
          "logs:DeleteLogStream",
          "logs:PutRetentionPolicy",
          "logs:DeleteRetentionPolicy",
          "logs:GetLogEvents",
          "logs:FilterLogEvents",
          "logs:StartQuery",
          "logs:StopQuery",
          "logs:GetQueryResults",
          "logs:DescribeQueries",
          "logs:CreateExportTask",
          "logs:DescribeExportTasks",
          "logs:CancelExportTask",
          "logs:PutMetricFilter",
          "logs:DeleteMetricFilter",
          "logs:DescribeMetricFilters",
          "logs:PutSubscriptionFilter",
          "logs:DeleteSubscriptionFilter",
          "logs:DescribeSubscriptionFilters"
        ]
        Resource = [
          "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/application/${var.project_name}-${var.environment}",
          "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/application/${var.project_name}-${var.environment}:*",
          "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/vpc/flow-logs/${var.project_name}-${var.environment}",
          "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/vpc/flow-logs/${var.project_name}-${var.environment}:*"
        ]
      }
    ]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-cloudwatch-admin-policy"
    Environment = var.environment
    Purpose     = "CloudWatch administration"
    Service     = "CloudWatch"
  }
}

module "cloudwatch_developer_policy" {
  source      = "../../modules/iam_policies"
  name        = "cloudwatch-developer-policy"
  description = "Developer access to CloudWatch resources (no delete)"
  path        = "/"

  policy_document = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents",
          "logs:FilterLogEvents",
          "logs:StartQuery",
          "logs:StopQuery",
          "logs:GetQueryResults",
          "logs:DescribeQueries",
          "logs:DescribeExportTasks",
          "logs:DescribeMetricFilters",
          "logs:DescribeSubscriptionFilters"
        ]
        Resource = [
          "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/application/${var.project_name}-${var.environment}",
          "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/application/${var.project_name}-${var.environment}:*",
          "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/vpc/flow-logs/${var.project_name}-${var.environment}",
          "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/vpc/flow-logs/${var.project_name}-${var.environment}:*"
        ]
      }
    ]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-cloudwatch-developer-policy"
    Environment = var.environment
    Purpose     = "CloudWatch development"
    Service     = "CloudWatch"
  }
}

module "cloudwatch_viewer_policy" {
  source      = "../../modules/iam_policies"
  name        = "cloudwatch-viewer-policy"
  description = "Read-only access to CloudWatch resources"
  path        = "/"

  policy_document = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents",
          "logs:FilterLogEvents",
          "logs:DescribeQueries",
          "logs:DescribeExportTasks",
          "logs:DescribeMetricFilters",
          "logs:DescribeSubscriptionFilters"
        ]
        Resource = [
          "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/application/${var.project_name}-${var.environment}",
          "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/application/${var.project_name}-${var.environment}:*",
          "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/vpc/flow-logs/${var.project_name}-${var.environment}",
          "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/vpc/flow-logs/${var.project_name}-${var.environment}:*"
        ]
      }
    ]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-cloudwatch-viewer-policy"
    Environment = var.environment
    Purpose     = "CloudWatch viewing"
    Service     = "CloudWatch"
  }
}

# CloudWatch Flow Log IAM Role and Policy
resource "aws_iam_role" "flow_log" {
  count = var.enable_vpc_flow_logs ? 1 : 0
  name  = "${var.project_name}-${var.environment}-flow-log-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-flow-log-role"
    Environment = var.environment
    Purpose     = "VPC flow logs"
    Service     = "CloudWatch"
  }
}

resource "aws_iam_role_policy" "flow_log" {
  count = var.enable_vpc_flow_logs ? 1 : 0
  name  = "${var.project_name}-${var.environment}-flow-log-policy"
  role  = aws_iam_role.flow_log[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
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
          "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/vpc/flow-logs/${var.project_name}-${var.environment}",
          "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/vpc/flow-logs/${var.project_name}-${var.environment}:*"
        ]
      }
    ]
  })
}

module "kms_admin_policy" {
  source      = "../../modules/iam_policies"
  name        = "kms-admin-policy"
  description = "Full access to KMS"
  path        = "/"

  policy_document = {
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "kms:CreateKey",
        "kms:CreateAlias",
        "kms:DeleteAlias",
        "kms:UpdateAlias",
        "kms:DescribeKey",
        "kms:EnableKey",
        "kms:DisableKey",
        "kms:ScheduleKeyDeletion",
        "kms:CancelKeyDeletion",
        "kms:PutKeyPolicy",
        "kms:GetKeyPolicy",
        "kms:ListKeys",
        "kms:ListAliases",
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:GenerateDataKey",
        "kms:GenerateDataKeyWithoutPlaintext"
      ]
      Resource = [
        module.main_kms_key.arn,
        aws_kms_key.s3_key.arn
      ]
    }]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-kms-admin-policy"
    Environment = var.environment
    Purpose     = "KMS administration"
    Service     = "KMS"
  }
}

module "kms_developer_policy" {
  source      = "../../modules/iam_policies"
  name        = "kms-developer-policy"
  description = "Encrypt/Decrypt access to KMS (no delete)"
  path        = "/"

  policy_document = {
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:GenerateDataKey",
        "kms:GenerateDataKeyWithoutPlaintext",
        "kms:DescribeKey"
      ]
      Resource = [
        module.main_kms_key.arn,
        aws_kms_key.s3_key.arn
      ]
    }]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-kms-developer-policy"
    Environment = var.environment
    Purpose     = "KMS development"
    Service     = "KMS"
  }
}

module "kms_viewer_policy" {
  source      = "../../modules/iam_policies"
  name        = "kms-viewer-policy"
  description = "Read-only access to KMS"
  path        = "/"

  policy_document = {
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "kms:DescribeKey",
        "kms:ListKeys",
        "kms:ListAliases"
      ]
      Resource = [
        module.main_kms_key.arn,
        aws_kms_key.s3_key.arn
      ]
    }]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-kms-viewer-policy"
    Environment = var.environment
    Purpose     = "KMS viewing"
    Service     = "KMS"
  }
}

module "iam_admin_policy" {
  source      = "../../modules/iam_policies"
  name        = "iam-admin-policy"
  description = "Full access to IAM"
  path        = "/"

  policy_document = {
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "iam:CreateUser",
        "iam:DeleteUser",
        "iam:GetUser",
        "iam:ListUsers",
        "iam:UpdateUser",
        "iam:CreateGroup",
        "iam:DeleteGroup",
        "iam:GetGroup",
        "iam:ListGroups",
        "iam:UpdateGroup",
        "iam:CreatePolicy",
        "iam:DeletePolicy",
        "iam:GetPolicy",
        "iam:ListPolicies",
        "iam:AttachUserPolicy",
        "iam:DetachUserPolicy",
        "iam:AttachGroupPolicy",
        "iam:DetachGroupPolicy",
        "iam:ListAttachedUserPolicies",
        "iam:ListAttachedGroupPolicies"
      ]
      Resource = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${var.project_name}-*",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:group/${var.project_name}-*",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.project_name}-*"
      ]
    }]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-iam-admin-policy"
    Environment = var.environment
    Purpose     = "IAM administration"
    Service     = "IAM"
  }
}

module "iam_developer_policy" {
  source      = "../../modules/iam_policies"
  name        = "iam-developer-policy"
  description = "Developer access to IAM (no delete)"
  path        = "/"

  policy_document = {
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "iam:GetUser",
        "iam:ListUsers",
        "iam:GetGroup",
        "iam:ListGroups",
        "iam:GetPolicy",
        "iam:ListPolicies",
        "iam:ListAttachedUserPolicies",
        "iam:ListAttachedGroupPolicies",
        "iam:PassRole"
      ]
      Resource = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${var.project_name}-*",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:group/${var.project_name}-*",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.project_name}-*"
      ]
    }]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-iam-developer-policy"
    Environment = var.environment
    Purpose     = "IAM development"
    Service     = "IAM"
  }
}

module "iam_viewer_policy" {
  source      = "../../modules/iam_policies"
  name        = "iam-viewer-policy"
  description = "Read-only access to IAM"
  path        = "/"

  policy_document = {
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "iam:GetUser",
        "iam:ListUsers",
        "iam:GetGroup",
        "iam:ListGroups",
        "iam:GetPolicy",
        "iam:ListPolicies",
        "iam:ListAttachedUserPolicies",
        "iam:ListAttachedGroupPolicies"
      ]
      Resource = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${var.project_name}-*",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:group/${var.project_name}-*",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.project_name}-*"
      ]
    }]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-iam-viewer-policy"
    Environment = var.environment
    Purpose     = "IAM viewing"
    Service     = "IAM"
  }
}
