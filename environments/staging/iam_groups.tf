# S3 Groups

module "s3_admin_group" {
  source      = "../../modules/iam_groups"
  group_name  = "s3-admin"
  path        = "/"
  enforce_mfa = true
  policy_arn_map = {
    s3 = module.s3_admin_policy.arn
  }
}

module "s3_developer_group" {
  source      = "../../modules/iam_groups"
  group_name  = "s3-developer"
  path        = "/"
  enforce_mfa = true
  policy_arn_map = {
    s3 = module.s3_developer_policy.arn
  }
}

module "s3_viewer_group" {
  source      = "../../modules/iam_groups"
  group_name  = "s3-viewer"
  path        = "/"
  enforce_mfa = true
  policy_arn_map = {
    s3 = module.s3_viewer_policy.arn
  }
}

# KMS Groups

module "kms_admin_group" {
  source      = "../../modules/iam_groups"
  group_name  = "kms-admin"
  path        = "/"
  enforce_mfa = true
  policy_arn_map = {
    kms = module.kms_admin_policy.arn
  }
}

module "kms_developer_group" {
  source      = "../../modules/iam_groups"
  group_name  = "kms-developer"
  path        = "/"
  enforce_mfa = true
  policy_arn_map = {
    kms = module.kms_developer_policy.arn
  }
}

module "kms_viewer_group" {
  source      = "../../modules/iam_groups"
  group_name  = "kms-viewer"
  path        = "/"
  enforce_mfa = true
  policy_arn_map = {
    kms = module.kms_viewer_policy.arn
  }
}

# VPC Groups

module "vpc_admin_group" {
  source      = "../../modules/iam_groups"
  group_name  = "vpc-admin"
  path        = "/"
  enforce_mfa = true
  policy_arn_map = {
    vpc = module.vpc_admin_policy.arn
  }
}

module "vpc_developer_group" {
  source      = "../../modules/iam_groups"
  group_name  = "vpc-developer"
  path        = "/"
  enforce_mfa = true
  policy_arn_map = {
    vpc = module.vpc_developer_policy.arn
  }
}

module "vpc_viewer_group" {
  source      = "../../modules/iam_groups"
  group_name  = "vpc-viewer"
  path        = "/"
  enforce_mfa = true
  policy_arn_map = {
    vpc = module.vpc_viewer_policy.arn
  }
}

# CloudWatch Groups

module "cloudwatch_admin_group" {
  source      = "../../modules/iam_groups"
  group_name  = "cloudwatch-admin"
  path        = "/"
  enforce_mfa = true
  policy_arn_map = {
    cloudwatch = module.cloudwatch_admin_policy.arn
  }
}

module "cloudwatch_developer_group" {
  source      = "../../modules/iam_groups"
  group_name  = "cloudwatch-developer"
  path        = "/"
  enforce_mfa = true
  policy_arn_map = {
    cloudwatch = module.cloudwatch_developer_policy.arn
  }
}

module "cloudwatch_viewer_group" {
  source      = "../../modules/iam_groups"
  group_name  = "cloudwatch-viewer"
  path        = "/"
  enforce_mfa = true
  policy_arn_map = {
    cloudwatch = module.cloudwatch_viewer_policy.arn
  }
}

# IAM Admin Group

module "iam_admin_group" {
  source      = "../../modules/iam_groups"
  group_name  = "iam-admin"
  path        = "/"
  enforce_mfa = true
  policy_arn_map = {
    iam = module.iam_admin_policy.arn
  }
}

# Composite Groups

module "admin_group" {
  source      = "../../modules/iam_groups"
  group_name  = "admin"
  path        = "/"
  enforce_mfa = true
  policy_arn_map = {
    s3         = module.s3_admin_policy.arn,
    kms        = module.kms_admin_policy.arn,
    iam        = module.iam_admin_policy.arn,
    vpc        = module.vpc_admin_policy.arn,
    cloudwatch = module.cloudwatch_admin_policy.arn
  }
}

module "developer_group" {
  source      = "../../modules/iam_groups"
  group_name  = "developer"
  path        = "/"
  enforce_mfa = true
  policy_arn_map = {
    s3         = module.s3_developer_policy.arn,
    kms        = module.kms_developer_policy.arn,
    vpc        = module.vpc_developer_policy.arn,
    cloudwatch = module.cloudwatch_developer_policy.arn
  }
}

module "viewer_group" {
  source      = "../../modules/iam_groups"
  group_name  = "viewer"
  path        = "/"
  enforce_mfa = true
  policy_arn_map = {
    s3         = module.s3_viewer_policy.arn,
    kms        = module.kms_viewer_policy.arn,
    vpc        = module.vpc_viewer_policy.arn,
    cloudwatch = module.cloudwatch_viewer_policy.arn
  }
}
