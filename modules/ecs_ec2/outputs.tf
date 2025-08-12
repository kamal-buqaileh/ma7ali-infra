# ECS EC2 module outputs

output "launch_template_id" {
  description = "The ID of the launch template"
  value       = aws_launch_template.this.id
}

output "launch_template_arn" {
  description = "The ARN of the launch template"
  value       = aws_launch_template.this.arn
}

output "launch_template_latest_version" {
  description = "The latest version of the launch template"
  value       = aws_launch_template.this.latest_version
}

output "autoscaling_group_id" {
  description = "The ID of the Auto Scaling Group"
  value       = aws_autoscaling_group.this.id
}

output "autoscaling_group_arn" {
  description = "The ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.this.arn
}

output "autoscaling_group_name" {
  description = "The name of the Auto Scaling Group"
  value       = aws_autoscaling_group.this.name
}

output "capacity_provider_name" {
  description = "The name of the ECS capacity provider"
  value       = aws_ecs_capacity_provider.this.name
}

output "capacity_provider_arn" {
  description = "The ARN of the ECS capacity provider"
  value       = aws_ecs_capacity_provider.this.arn
}

output "security_group_id" {
  description = "The ID of the ECS instances security group (if created)"
  value       = var.create_security_group ? aws_security_group.this[0].id : null
}

output "security_group_arn" {
  description = "The ARN of the ECS instances security group (if created)"
  value       = var.create_security_group ? aws_security_group.this[0].arn : null
}

output "ami_id" {
  description = "The AMI ID used for instances"
  value       = var.ami_id != "" ? var.ami_id : data.aws_ami.ecs_optimized.id
}

output "ami_name" {
  description = "The name of the AMI used for instances"
  value       = data.aws_ami.ecs_optimized.name
}

output "ami_description" {
  description = "The description of the AMI used for instances"
  value       = data.aws_ami.ecs_optimized.description
}

output "instance_profile_name" {
  description = "The name of the IAM instance profile used"
  value       = var.instance_profile_name
}

output "cluster_name" {
  description = "The ECS cluster name this capacity provider is associated with"
  value       = var.cluster_name
}
