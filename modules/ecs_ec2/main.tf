# ECS EC2 Capacity Provider module
# This module creates EC2 instances and Auto Scaling Groups specifically for ECS clusters

# Data source for ECS-optimized AMI
data "aws_ami" "ecs_optimized" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = var.ami_type == "arm64" ? ["amzn2-ami-ecs-hvm-*-arm64-ebs"] : ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Launch Template for ECS instances
resource "aws_launch_template" "this" {
  name_prefix   = "${var.cluster_name}-"
  image_id      = var.ami_id != "" ? var.ami_id : data.aws_ami.ecs_optimized.id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = var.security_group_ids

  iam_instance_profile {
    name = var.instance_profile_name
  }

  # Minimal user data - only ECS cluster configuration
  user_data = base64encode("#!/bin/bash\necho ECS_CLUSTER=${var.cluster_name} >> /etc/ecs/ecs.config")

  # Enhanced security for instance metadata
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
    http_put_response_hop_limit = 2
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.volume_size
      volume_type          = var.volume_type
      delete_on_termination = true
      encrypted            = true
      kms_key_id          = var.kms_key_arn
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name = "${var.cluster_name}-ecs-instance"
    })
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "this" {
  name                = "${var.cluster_name}-asg"
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = var.target_group_arns
  health_check_type   = "EC2"
  health_check_grace_period = var.health_check_grace_period

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  # Enable instance scale-in protection
  protect_from_scale_in = var.protect_from_scale_in

  # Termination policies
  termination_policies = var.termination_policies

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-ecs-asg"
    propagate_at_launch = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes       = [desired_capacity]
  }
}

# ECS Capacity Provider
resource "aws_ecs_capacity_provider" "this" {
  name = "${var.cluster_name}-ec2"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.this.arn
    managed_termination_protection = var.protect_from_scale_in ? "ENABLED" : "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = var.max_scaling_step_size
      minimum_scaling_step_size = var.min_scaling_step_size
      status                    = var.enable_managed_scaling ? "ENABLED" : "DISABLED"
      target_capacity           = var.target_capacity
    }
  }

  tags = var.tags
}

# Security Group for ECS Instances
resource "aws_security_group" "this" {
  count = var.create_security_group ? 1 : 0

  name_prefix = "${var.cluster_name}-ecs-instances-"
  vpc_id      = var.vpc_id
  description = "Security group for ECS instances"

  # Allow inbound from ALB security groups
  dynamic "ingress" {
    for_each = var.alb_security_group_ids
    content {
      description     = "HTTP from ALB"
      from_port       = 32768
      to_port         = 65535
      protocol        = "tcp"
      security_groups = [ingress.value]
    }
  }

  # Allow SSH access if key is provided
  dynamic "ingress" {
    for_each = var.key_name != null ? var.ssh_allowed_cidr_blocks : []
    content {
      description = "SSH access"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  # Allow all outbound traffic
  # HTTPS outbound for package updates, ECR, and external APIs
  # tfsec:ignore:aws-ec2-no-public-egress-sgr - Required for external API calls and updates
  egress {
    description = "HTTPS outbound for external APIs (Stripe, SendGrid, etc.)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP outbound for package repositories and health checks
  # tfsec:ignore:aws-ec2-no-public-egress-sgr - Required for package updates via NAT Gateway
  egress {
    description = "HTTP outbound for package repositories"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # DNS outbound
  # tfsec:ignore:aws-ec2-no-public-egress-sgr - Required for domain name resolution
  egress {
    description = "DNS outbound for name resolution"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # NTP outbound for time synchronization
  # tfsec:ignore:aws-ec2-no-public-egress-sgr - Required for system time synchronization
  egress {
    description = "NTP outbound for time synchronization"
    from_port   = 123
    to_port     = 123
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # VPC internal communication
  egress {
    description = "VPC internal communication"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-ecs-instances-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}
