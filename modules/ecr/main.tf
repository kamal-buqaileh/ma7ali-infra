# ecr module

locals {
  repo_defs = var.repositories
}

resource "aws_ecr_repository" "this" {
  for_each             = local.repo_defs
  name                 = "${var.name_prefix}-${each.key}"
  image_tag_mutability = lookup(each.value, "image_tag_mutability", "IMMUTABLE")

  image_scanning_configuration {
    scan_on_push = lookup(each.value, "scan_on_push", true)
  }

  encryption_configuration {
    encryption_type = lookup(each.value, "encryption_type", "KMS")
    kms_key         = lookup(each.value, "kms_key_arn", null)
  }

  force_delete = lookup(each.value, "force_delete", false)

  tags = merge(var.tags, lookup(each.value, "tags", {}), {
    Name = "${var.name_prefix}-${each.key}"
  })
}

resource "aws_ecr_lifecycle_policy" "this" {
  for_each   = { for k, v in local.repo_defs : k => v if try(v.lifecycle_policy, null) != null }
  repository = aws_ecr_repository.this[each.key].name
  policy     = each.value.lifecycle_policy
}

