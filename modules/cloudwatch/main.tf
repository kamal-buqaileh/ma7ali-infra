# cloudwatch module

# Create CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "this" {
  for_each = var.log_groups

  name              = each.value.name
  retention_in_days = each.value.retention_in_days
  kms_key_id        = var.kms_key_id

  tags = merge(var.tags, each.value.tags, {
    Name = "${var.name}-${each.key}"
  })
}

# Create VPC Flow Logs if enabled
resource "aws_flow_log" "this" {
  count           = var.enable_vpc_flow_logs ? 1 : 0
  iam_role_arn    = var.flow_log_iam_role_arn
  log_destination = aws_cloudwatch_log_group.flow_log[0].arn
  traffic_type    = "ALL"
  vpc_id          = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name}-flow-logs"
  })
}

# Create CloudWatch Log Group for Flow Logs
resource "aws_cloudwatch_log_group" "flow_log" {
  count             = var.enable_vpc_flow_logs ? 1 : 0
  name              = "/aws/vpc/flow-logs/${var.name}"
  retention_in_days = var.flow_log_retention_days
  kms_key_id        = var.kms_key_id

  tags = merge(var.tags, {
    Name = "${var.name}-flow-logs"
  })
}
