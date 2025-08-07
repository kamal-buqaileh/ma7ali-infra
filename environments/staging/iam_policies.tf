# Data sources for specific resources
data "aws_caller_identity" "current" {}

module "s3_admin_policy" {
  source      = "../../modules/iam_policies"
  name        = "s3-admin-policy"
  description = "Full access to S3"
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
}

module "s3_developer_policy" {
  source      = "../../modules/iam_policies"
  name        = "s3-developer-policy"
  description = "Read/Write access to S3 (no delete)"
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
}

module "s3_viewer_policy" {
  source      = "../../modules/iam_policies"
  name        = "s3-viewer-policy"
  description = "Read-only access to S3"
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
}

module "kms_admin_policy" {
  source      = "../../modules/iam_policies"
  name        = "kms-admin-policy"
  description = "Full access to KMS"
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
}

module "kms_developer_policy" {
  source      = "../../modules/iam_policies"
  name        = "kms-developer-policy"
  description = "Encrypt/Decrypt access to KMS (no delete)"
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
}

module "kms_viewer_policy" {
  source      = "../../modules/iam_policies"
  name        = "kms-viewer-policy"
  description = "Read-only access to KMS"
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
}

module "iam_admin_policy" {
  source      = "../../modules/iam_policies"
  name        = "iam-admin-policy"
  description = "Full access to IAM"
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
}

module "iam_developer_policy" {
  source      = "../../modules/iam_policies"
  name        = "iam-developer-policy"
  description = "Developer access to IAM (no delete)"
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
}

module "iam_viewer_policy" {
  source      = "../../modules/iam_policies"
  name        = "iam-viewer-policy"
  description = "Read-only access to IAM"
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
}
