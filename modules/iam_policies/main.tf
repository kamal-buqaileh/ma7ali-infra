# Create an IAM policy for managing permissions
# This policy can be attached to users, groups, or roles to grant specific permissions
resource "aws_iam_policy" "this" {
  name        = var.name
  description = var.description
  policy      = jsonencode(var.policy_document)
  path        = var.path

  tags = var.tags
}
