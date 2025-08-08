# ecr configuration
# TODO: Create a custom KMS key for ECR in production
module "ecr" {
  source      = "../../modules/ecr"
  name_prefix = "${var.project_name}-${var.environment}"

  repositories = {
    backend = {
      image_tag_mutability = "IMMUTABLE"
      scan_on_push         = true
      encryption_type      = "KMS"
      kms_key_arn          = module.main_kms_key.arn
      force_delete         = true
      lifecycle_policy = jsonencode({
        rules = [
          {
            rulePriority = 1
            description  = "Keep last 10 images"
            selection = {
              tagStatus   = "any"
              countType   = "imageCountMoreThan"
              countNumber = 10
            }
            action = { type = "expire" }
          }
        ]
      })
      tags = { Service = "backend" }
    }
    frontend = {
      image_tag_mutability = "IMMUTABLE"
      scan_on_push         = true
      encryption_type      = "KMS"
      kms_key_arn          = module.main_kms_key.arn
      force_delete         = true
      lifecycle_policy = jsonencode({
        rules = [
          {
            rulePriority = 1
            description  = "Keep last 10 images"
            selection = {
              tagStatus   = "any"
              countType   = "imageCountMoreThan"
              countNumber = 10
            }
            action = { type = "expire" }
          }
        ]
      })
      tags = { Service = "frontend" }
    }
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

output "ecr_repository_urls" {
  value       = module.ecr.repository_urls
  description = "Map of ECR repository URLs for pushing images"
}

