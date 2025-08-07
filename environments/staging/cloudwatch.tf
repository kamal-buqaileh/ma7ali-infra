module "cloudwatch" {
  source = "../../modules/cloudwatch"

  name   = "${var.project_name}-${var.environment}"
  vpc_id = module.vpc.vpc_id

  enable_vpc_flow_logs    = var.enable_vpc_flow_logs
  flow_log_retention_days = 7
  flow_log_iam_role_arn   = var.enable_vpc_flow_logs ? aws_iam_role.flow_log[0].arn : null
  kms_key_id              = module.main_kms_key.arn

  log_groups = {
    application = {
      name              = "/aws/application/${var.project_name}-${var.environment}"
      retention_in_days = 7
      tags = {
        Purpose = "Application logs"
      }
    }
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}
