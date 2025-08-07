module "admin_user" {
  source    = "../../modules/iam_users"
  user_name = "admin"
  path      = "/"
  group_names = [
    module.admin_group.group_name
  ]

  tags = {
    Name        = "${var.project_name}-${var.environment}-admin-user"
    Environment = var.environment
    Purpose     = "Administration"
    Role        = "Admin"
  }
}

module "developer_user" {
  source    = "../../modules/iam_users"
  user_name = "developer"
  path      = "/"
  group_names = [
    module.s3_developer_group.group_name,
    module.kms_developer_group.group_name
  ]

  tags = {
    Name        = "${var.project_name}-${var.environment}-developer-user"
    Environment = var.environment
    Purpose     = "Development"
    Role        = "Developer"
  }
}

module "viewer_user" {
  source    = "../../modules/iam_users"
  user_name = "viewer"
  path      = "/"
  group_names = [
    module.viewer_group.group_name
  ]

  tags = {
    Name        = "${var.project_name}-${var.environment}-viewer-user"
    Environment = var.environment
    Purpose     = "Viewing"
    Role        = "Viewer"
  }
}
