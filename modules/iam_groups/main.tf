# Create an IAM group for organizing users and managing permissions
# Groups provide a way to attach policies to multiple users at once
resource "aws_iam_group" "this" {
  name = var.group_name
  path = var.path
}

# Attach policies to the group using a map of policy ARNs
# This allows for flexible policy attachment without hardcoding
resource "aws_iam_group_policy_attachment" "attachments" {
  for_each = var.policy_arn_map

  group      = aws_iam_group.this.name
  policy_arn = each.value
}

# MFA enforcement policy for enhanced security
# This policy denies all actions except MFA-related ones when MFA is not present
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
