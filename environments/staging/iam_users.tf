module "admin_user" {
  source    = "../../modules/iam_users"
  user_name = "admin"
  group_names = [
    module.admin_group.group_name
  ]
}

module "developer_user" {
  source    = "../../modules/iam_users"
  user_name = "developer"
  group_names = [
    module.s3_developer_group.group_name,
    module.kms_developer_group.group_name
  ]
}

module "viewer_user" {
  source    = "../../modules/iam_users"
  user_name = "viewer"
  group_names = [
    module.viewer_group.group_name
  ]
}
