# S3 Groups

module "s3_admin_group" {
  source      = "../../modules/iam_groups"
  group_name  = "s3-admin"
  enforce_mfa = true
  policy_arn_map = {
    s3 = module.s3_admin_policy.arn
  }
}

module "s3_viewer_group" {
  source      = "../../modules/iam_groups"
  group_name  = "s3-viewer"
  enforce_mfa = true
  policy_arn_map = {
    s3 = module.s3_viewer_policy.arn
  }
}

module "s3_developer_group" {
  source      = "../../modules/iam_groups"
  group_name  = "s3-developer"
  enforce_mfa = true
  policy_arn_map = {
    s3 = module.s3_developer_policy.arn
  }
}

# KMS Groups

module "kms_admin_group" {
  source      = "../../modules/iam_groups"
  group_name  = "kms-admin"
  enforce_mfa = true
  policy_arn_map = {
    kms = module.kms_admin_policy.arn
  }
}

module "kms_viewer_group" {
  source      = "../../modules/iam_groups"
  group_name  = "kms-viewer"
  enforce_mfa = true
  policy_arn_map = {
    kms = module.kms_viewer_policy.arn
  }
}

module "kms_developer_group" {
  source      = "../../modules/iam_groups"
  group_name  = "kms-developer"
  enforce_mfa = true
  policy_arn_map = {
    kms = module.kms_developer_policy.arn
  }
}

# IAM Admin Group

module "iam_admin_group" {
  source      = "../../modules/iam_groups"
  group_name  = "iam-admin"
  enforce_mfa = true
  policy_arn_map = {
    iam = module.iam_admin_policy.arn
  }
}

# Composite Groups

module "admin_group" {
  source      = "../../modules/iam_groups"
  group_name  = "admin"
  enforce_mfa = true
  policy_arn_map = {
    s3  = module.s3_admin_policy.arn,
    kms = module.kms_admin_policy.arn,
    iam = module.iam_admin_policy.arn
  }
}

module "viewer_group" {
  source      = "../../modules/iam_groups"
  group_name  = "viewer"
  enforce_mfa = true
  policy_arn_map = {
    s3  = module.s3_viewer_policy.arn,
    kms = module.kms_viewer_policy.arn
  }
}

module "developer_group" {
  source      = "../../modules/iam_groups"
  group_name  = "developer"
  enforce_mfa = true
  policy_arn_map = {
    s3  = module.s3_developer_policy.arn,
    kms = module.kms_developer_policy.arn
  }
}
