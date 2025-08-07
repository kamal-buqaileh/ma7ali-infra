resource "aws_iam_group" "this" {
  name = var.group_name
}

resource "aws_iam_group_policy_attachment" "attachments" {
  for_each = var.policy_arn_map

  group      = aws_iam_group.this.name
  policy_arn = each.value
}

# MFA enforcement policy
resource "aws_iam_group_policy" "mfa_enforcement" {
  count  = var.enforce_mfa ? 1 : 0
  name   = "${var.group_name}-mfa-enforcement"
  group  = aws_iam_group.this.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyAllExceptListedIfNoMFA"
        Effect = "Deny"
        NotAction = [
          "iam:CreateVirtualMFADevice",
          "iam:EnableMFADevice",
          "iam:GetUser",
          "iam:ListMFADevices",
          "iam:ListVirtualMFADevices",
          "iam:ResyncMFADevice",
          "iam:ChangePassword",
          "iam:GetAccountPasswordPolicy"
        ]
        Resource = "*"
        Condition = {
          BoolIfExists = {
            "aws:MultiFactorAuthPresent" = "false"
          }
        }
      }
    ]
  })
}
