resource "aws_iam_policy" "this" {
  name        = var.name
  description = var.description
  policy      = jsonencode(var.policy_document)
}
