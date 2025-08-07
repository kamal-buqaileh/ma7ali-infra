resource "aws_iam_user" "this" {
  name = var.user_name
  path = "/"
}

resource "aws_iam_user_group_membership" "this" {
  user = aws_iam_user.this.name
  groups = var.group_names
}
