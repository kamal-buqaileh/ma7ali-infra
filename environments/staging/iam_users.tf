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
    module.developer_group.group_name
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

# GitHub OIDC Identity Provider
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]

  tags = {
    Name        = "${var.project_name}-${var.environment}-github-oidc"
    Environment = var.environment
    Purpose     = "GitHub Actions OIDC"
  }
}

# IAM Role for GitHub Actions
resource "aws_iam_role" "github_actions_deployer" {
  name = "${var.project_name}-${var.environment}-github-actions-deployer"
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = [
              for repo in var.github_repositories : "repo:${repo}:*"
            ]
          }
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-github-actions-deployer"
    Environment = var.environment
    Purpose     = "GitHub Actions CI/CD Role"
    Role        = "Deployer"
  }
}

# Attach the ECR deployer policy to the role
resource "aws_iam_role_policy_attachment" "github_actions_ecr_deployer" {
  role       = aws_iam_role.github_actions_deployer.name
  policy_arn = module.ecr_deployer_policy.arn
}
