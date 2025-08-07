# Create an IAM user for individual access management
# Users represent individual people or applications that need AWS access
resource "aws_iam_user" "this" {
  name = var.user_name
  path = var.path

  tags = var.tags
}

# Assign the user to multiple groups for flexible permission management
# This allows users to inherit permissions from multiple groups
resource "aws_iam_user_group_membership" "this" {
  user   = aws_iam_user.this.name
  groups = var.group_names
}
